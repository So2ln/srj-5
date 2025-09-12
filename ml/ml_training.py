import pandas as pd
import numpy as np
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.decomposition import PCA
from lightgbm import LGBMClassifier
from sklearn.metrics import accuracy_score, classification_report

# 이 스크립트는 실제 데이터가 있다는 가정 하에 모델 학습 과정을 보여줍니다.
# 실행을 위해서는 `pip install pandas scikit-learn lightgbm` 이 필요합니다.

def create_dummy_data(num_samples=1000):
    """모델 학습 과정을 시연하기 위한 더미 데이터 생성"""
    data = {
        'icon': np.random.choice(['anxiety', 'anger', 'depression', 'calm'], num_samples),
        'intensity_pre': np.random.randint(4, 11, num_samples),
        'contexts': np.random.choice(['work', 'people', 'home', 'none'], num_samples),
        'time_of_day': np.random.choice(['morning', 'afternoon', 'evening'], num_samples),
        'rses_score': np.random.randint(15, 41, num_samples),
        # 실제로는 SBERT 임베딩 결과가 와야 함
        **{f'embedding_{i}': np.random.randn(num_samples) for i in range(384)},
        'intervention_done': np.random.choice([True, False], num_samples, p=[0.7, 0.3]),
        'intensity_post': np.random.randint(1, 9, num_samples),
    }
    df = pd.DataFrame(data)
    
    # 라벨(y) 생성: 개입 실행 후 강도 변화가 2 이상이면 성공(1)
    df['intensity_delta'] = df['intensity_pre'] - df['intensity_post']
    df['label_anxiety'] = ((df['intervention_done']) & (df['intensity_delta'] >= 2) & (df['icon'] == 'anxiety')).astype(int)
    
    return df

def train_model():
    """데이터로 모델을 학습하고 파일을 저장하는 메인 함수"""
    print("1. 데이터 로드 및 생성...")
    df = create_dummy_data()
    
    # 독립 변수(X)와 종속 변수(y) 분리
    # 'anxiety' 클러스터에 대한 추천 성공 여부를 예측하는 모델
    y = df['label_anxiety']
    X = df.drop(columns=['label_anxiety', 'intervention_done', 'intensity_post', 'intensity_delta'])

    print("2. 피처 엔지니어링 파이프라인 설정...")
    
    # 범주형/수치형/임베딩 피처 이름 정의
    categorical_features = ['icon', 'contexts', 'time_of_day']
    numerical_features = ['intensity_pre', 'rses_score']
    embedding_features = [f'embedding_{i}' for i in range(384)]
    
    # 전처리 파이프라인 구성
    # 1. 임베딩 벡터는 PCA로 32차원으로 축소 후 스케일링
    embedding_pipeline = Pipeline([
        ('pca', PCA(n_components=32)),
        ('scaler', StandardScaler())
    ])
    # 2. 수치형 데이터는 스케일링
    # 3. 범주형 데이터는 원-핫 인코딩
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', StandardScaler(), numerical_features),
            ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_features),
            ('embed', embedding_pipeline, embedding_features)
        ],
        remainder='passthrough' # 나머지 피처는 그대로 둠
    )

    print("3. 데이터 분할 및 모델 학습...")
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
    
    # 최종 모델 파이프라인: 전처리 -> LightGBM 학습
    model_pipeline = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('classifier', LGBMClassifier(random_state=42))
    ])
    
    model_pipeline.fit(X_train, y_train)

    print("4. 모델 평가...")
    y_pred = model_pipeline.predict(X_test)
    print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))

    print("5. 학습된 모델 및 파이프라인 저장...")
    joblib.dump(model_pipeline, 'anxiety_model_pipeline.joblib')
    print("모델이 'anxiety_model_pipeline.joblib' 파일로 저장되었습니다.")

if __name__ == '__main__':
    train_model()