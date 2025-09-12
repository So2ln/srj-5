// 텍스트를 소문자/정규화 → 키워드 매칭 → raw 점수 계산
// 강화/약화어로 가중
// 폭력 의도 플래그 추출

// Dart 의사코드 느낌: double lexScore(String note, List words) { ... }
// Map<String,double> ruleTextScore(String note) { ... }
// bool detectOtherHarm(String note) { ... }
