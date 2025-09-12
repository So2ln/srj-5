// 입력:
// icon, intensity, contexts, timeOfDay, textScores 가중 합(예):
// icon: +0.30 해당 클러스터에
// intensity: +0.20*(intensity/10.0) 해당 icon 축에
// context:
// work → anxiety +0.05, burnout +0.05
// people → anxiety +0.08, anger +0.03
// night → depression +0.05
// time:
// morning → anxiety +0.05
// night → depression +0.03
// text: 각 클러스터 +0.15*textScores[cluster]
// pattern: v0에선 0.0 고정(나중에 최근7일 패턴 붙이기)

//정규화:
// 최대값이 1.0 넘으면 전체를 max로 나눠 0~1 사이 유지

//top/secondary:
// 최댓값 클러스터를 top으로, 그다음이 0.2 이상이면 secondary
