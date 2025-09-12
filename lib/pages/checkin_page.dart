// // 텍스트 입력(TextField), 아이콘 선택(간단 Dropdown), 강도(Slider), 맥락(Chip 6개 중 다중 선택)
// // “추천 보기” 버튼 → recommend_usecase.run 호출 → 결과를 Card에 표시
// // 결과 표시:
// // topCluster, 점수 맵
// // intervention.preset, steps 리스트
// // reasonCard
// // safety 플래그 있으면 “10초 지연” 같은 퀵 버튼 노출
// // main.dart에서 home: CheckInPage()

// import 'package:flutter/material.dart';
// import '../models/checkin.dart';
// import '../usecases/recommend_usecase.dart';

// class CheckInPage extends StatefulWidget {
//   const CheckInPage({super.key});
//   @override
//   State<CheckInPage> createState() => _CheckInPageState();
// }

// class _CheckInPageState extends State<CheckInPage> {
//   final _noteCtrl = TextEditingController();
//   String _icon = 'anger';
//   double _intensity = 7;
//   final Set<String> _contexts = {'work', 'people'};
//   final _uc = RecommendUseCase();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('SRJ-4 체크인 데모')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             const Text('메모'),
//             TextField(
//               controller: _noteCtrl,
//               minLines: 2,
//               maxLines: 3,
//               decoration: const InputDecoration(hintText: '한 줄 메모를 입력'),
//             ),
//             const SizedBox(height: 12),
//             const Text('감정'),
//             DropdownButton<String>(
//               value: _icon,
//               items: const [
//                 DropdownMenuItem(value: 'anxiety', child: Text('불안')),
//                 DropdownMenuItem(value: 'depression', child: Text('우울')),
//                 DropdownMenuItem(value: 'panic', child: Text('공포/패닉')),
//                 DropdownMenuItem(value: 'anger', child: Text('분노/과민')),
//                 DropdownMenuItem(value: 'numb', child: Text('무감각/공허')),
//                 DropdownMenuItem(value: 'burnout', child: Text('피로/번아웃')),
//                 DropdownMenuItem(value: 'recovery', child: Text('차분/안정')),
//               ],
//               onChanged: (v) {
//                 setState(() => _icon = v!);
//               },
//             ),
//             const SizedBox(height: 12),
//             Text('강도: ${_intensity.toInt()} / 10'),
//             Slider(
//               value: _intensity,
//               min: 0,
//               max: 10,
//               divisions: 10,
//               onChanged: (v) {
//                 setState(() => _intensity = v);
//               },
//             ),
//             const SizedBox(height: 12),
//             const Text('맥락'),
//             Wrap(
//               spacing: 8,
//               children: ['work', 'home', 'people', 'alone', 'night', 'commute']
//                   .map((c) {
//                     final sel = _contexts.contains(c);
//                     return FilterChip(
//                       label: Text(c),
//                       selected: sel,
//                       onSelected: (v) {
//                         setState(() {
//                           if (v) {
//                             _contexts.add(c);
//                           } else {
//                             _contexts.remove(c);
//                           }
//                         });
//                       },
//                     );
//                   })
//                   .toList(),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 final c = Checkin(
//                   note: _noteCtrl.text,
//                   icon: _icon,
//                   intensity: _intensity.toInt(),
//                   contexts: _contexts.toList(),
//                 );
//                 final (scores, iv, safety) = await _uc.run(c);
//                 if (!mounted) return;
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (_) {
//                     return Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Top: ${scores.top}'),
//                             const SizedBox(height: 8),
//                             Text('Scores: ${scores.scores}'),
//                             const Divider(),
//                             Text('추천 루틴: ${iv.preset}'),
//                             ...iv.steps.map(
//                               (e) => ListTile(
//                                 leading: const Icon(Icons.check),
//                                 title: Text(e),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text('이유: ${iv.reasonCard}'),
//                             const SizedBox(height: 8),
//                             if (safety)
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red[50],
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: const Text(
//                                   '안전 알림: 지금은 말/행동을 잠시 늦추자. 10초 지연 버튼을 눌러줘.',
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//               child: const Text('추천 보기'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
