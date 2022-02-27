import 'package:flutter/foundation.dart';

@immutable
class Country {
  final String callingCode;
  final String code;
  final String flag;
  final String nativeName;

  const Country({
    required this.callingCode,
    required this.code,
    required this.flag,
    required this.nativeName,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    try {
      String callingCode = '';

      var idd = json['idd'];
      callingCode = idd['root'];

      List<dynamic> iddSuffixes = idd['suffixes'];
      if (iddSuffixes.length == 1) {
        callingCode += iddSuffixes[0];
      }

      return Country(
        callingCode: callingCode,
        code: json['ccn3'],
        flag: json['flag'],
        nativeName: json['name']['common'], // TODO
      );
    } on dynamic {
      return const Country(callingCode: '', flag: '', nativeName: '', code: '');
    }
  }

  @override
  int get hashCode => code.hashCode;

  @override
  bool operator ==(dynamic other) => (other is Country && other.code == code);
}
