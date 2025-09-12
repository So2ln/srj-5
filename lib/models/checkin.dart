// // note: String
// // icon: String (‘anxiety’, ‘depression’, ‘panic’, ‘anger’, ‘numb’, ‘burnout’, ‘recovery’)
// // intensity: int (0~10)
// // contexts: List ([‘work’, ‘home’, ‘people’, ‘alone’, ‘night’, ‘commute’])
// // ts: DateTime

// class Checkin {
//   final String note; // 한 줄 메모
//   final String
//   icon; // 'anxiety' | 'depression' | 'panic' | 'anger' | 'numb' | 'burnout' | 'recovery'
//   final int intensity; // 0..10
//   final List<String>
//   contexts; // ['work','home','people','alone','night','commute']
//   final DateTime ts;

//   Checkin({
//     required this.note,
//     required this.icon,
//     required this.intensity,
//     required this.contexts,
//     DateTime? ts,
//   }) : ts = ts ?? DateTime.now();
// }
