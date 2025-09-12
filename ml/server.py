from flask import Flask, request, jsonify
import joblib
import pandas as pd
import numpy as np

# 이 스크립트는 학습된 모델을 API로 서빙하는 예제입니다.
# 실행을 위해서는 `pip install Flask pandas scikit-learn lightgbm` 이 필요합니다.

app = Flask(__name__)

# 서버 시작 시 학습된 모델 파이프라인을 미리 로드
try:
    model_pipeline = joblib.load('ml/anxiety_model_pipeline.joblib')
    print("모델 로드 성공!")
except FileNotFoundError:
    model_pipeline = None
    print("오류: 'ml/anxiety_model_pipeline.joblib' 파일을 찾을 수 없습니다. 먼저 ml_training.py를 실행하세요.")

# 기획서에 정의된 클러스터 목록
CLUSTERS = ['depression', 'anxiety', 'anger', 'panic', 'lethargy', 'burnout', 'calm']


@app.route('/analyze', methods=['POST'])
def analyze():
    if model_pipeline is None:
        return jsonify({"error": "모델이 로드되지 않았습니다."}), 500

    data = request.get_json()
    print("요청 수신:", data)

    # --- LLM 게이트 로직 (서버 사이드) ---
    note = data.get('note', '')
    # 이 부분은 실제 LLM API 호출 로직으로 대체되어야 함
    # 지금은 LLM이 필요 없다고 가정하고 ML 스코어러만 사용
    
    # --- ML 스코어러를 위한 데이터 준비 ---
    # 앱에서 받은 JSON을 모델 입력 형식인 DataFrame으로 변환
    # 실제 환경에서는 사용자 프로필, 임베딩 등 모든 피처를 포함해야 함
    input_data = {
        'icon': [data.get('icon', 'anxiety')],
        'intensity_pre': [data.get('intensity', 7)],
        'contexts': [data.get('contexts', ['work'])[0]], # 리스트의 첫번째 요소 사용
        'time_of_day': [data.get('time_of_day', 'afternoon')],
        'rses_score': [data.get('user_profile', {}).get('rses_score', 25)],
        # 더미 임베딩 데이터 생성
        **{f'embedding_{i}': np.random.randn(1) for i in range(384)}
    }
    input_df = pd.DataFrame(input_data)
    
    # --- 예측 ---
    # 저장된 파이프라인은 전처리(스케일링, 인코딩 등)를 자동으로 수행
    # predict_proba는 각 클래스(0:실패, 1:성공)에 대한 확률을 반환
    # [:, 1]은 '성공' 클래스에 대한 확률만 추출
    try:
        anxiety_success_prob = model_pipeline.predict_proba(input_df)[0][1]
    except Exception as e:
        print("예측 오류:", e)
        return jsonify({"error": "모델 예측 중 오류 발생"}), 500

    print(f"불안(anxiety) 추천 성공 확률: {anxiety_success_prob:.4f}")
    
    # --- 응답 생성 ---
    # 다른 클러스터에 대해서도 각각의 모델로 확률을 계산했다고 가정
    cluster_probs = {cluster: np.random.rand() * 0.2 for cluster in CLUSTERS}
    cluster_probs['anxiety'] = anxiety_success_prob
    
    # 개인화 가중치 적용 (자존감 점수 기반)
    if data.get('user_profile', {}).get('rses_score', 30) < 20:
        cluster_probs['depression'] *= 1.2
        cluster_probs['anxiety'] *= 1.1

    # 가장 확률이 높은 클러스터 찾기
    main_cluster = max(cluster_probs, key=cluster_probs.get)
    
    response = {
        "main_cluster": main_cluster,
        "cluster_probabilities": cluster_probs,
        "intervention": {
            "routine_name": "4-7-8 호흡하기 (120초)",
            "type": "breathing"
        },
        "reason_card": f"분석 결과, '{main_cluster}' 상태일 가능성({cluster_probs[main_cluster]:.0%})이 가장 높게 나타났습니다."
    }

    return jsonify(response)


if __name__ == '__main__':
    # host='0.0.0.0'으로 설정하여 외부에서 접근 가능하게 함
    app.run(host='0.0.0.0', port=5000, debug=True)