import 'dart:convert';


String verifyHomeAccessToken(String token) {
  
  final encodedPayload = token.split('.')[1];
    final payloadData =
        utf8.fuse(base64).decode(base64.normalize(encodedPayload));
    Payload.fromJson(jsonDecode(payloadData));
    //Todo seperate roleType
    // final parsedPatient = Patients.fromJson(jsonEncode(jsonDecode(payloadData)));
    
    return payloadData;
}

class Payload {
  String? sub;
  String? name;
  String?expiresIn;
  int? iat;

  Payload({this.sub, this.name, this.iat,this.expiresIn});

  Payload.fromJson(Map<String, dynamic> json) {
    sub = json['sub'];
    name = json['name'];
    iat = json['iat'];
    expiresIn = json['expiresIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['sub'] = sub;
    data['name'] = name;
    data['iat'] = iat;
    data['expiresIn'] = expiresIn;
    return data;
  }
}
