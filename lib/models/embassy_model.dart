class EmbassyModel {
  final String embassyName;      // 공관명
  final String? ambassadorName;  // 공관장명
  final String? address;         // 주소
  final String? phoneNumber;     // 전화번호
  final String? faxNumber;       // 팩스번호
  final String? email;           // 이메일
  final String? embassyType;     // 공관유형 (대사관, 총영사관 등)
  final String? zipCode;         // 우편번호

  const EmbassyModel({
    required this.embassyName,
    this.ambassadorName,
    this.address,
    this.phoneNumber,
    this.faxNumber,
    this.email,
    this.embassyType,
    this.zipCode,
  });

  factory EmbassyModel.fromJson(Map<String, dynamic> json) {
    return EmbassyModel(
      embassyName:     json['embassy_nm']        ?? '',
      ambassadorName:  json['ambassador_nm'],
      address:         json['addr'],
      phoneNumber:     json['tel_no'],
      faxNumber:       json['fax_no'],
      email:           json['email'],
      embassyType:     json['inko_embassy_ty'],
      zipCode:         json['zip'],
    );
  }
}
