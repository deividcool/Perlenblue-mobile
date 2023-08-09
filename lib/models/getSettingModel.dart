class GetSettingModel {
  String responseCode;
  String message;
  Settings settings;
  String status;

  GetSettingModel(
      {this.responseCode, this.message, this.settings, this.status});

  GetSettingModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    settings = json['settings'] != null
        ? new Settings.fromJson(json['settings'])
        : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response_code'] = this.responseCode;
    data['message'] = this.message;
    if (this.settings != null) {
      data['settings'] = this.settings.toJson();
    }
    data['status'] = this.status;
    return data;
  }
}

class Settings {
  String id;
  String notifyKey;
  String prvPolUrl;
  String tncUrl;

  Settings({this.id, this.notifyKey, this.prvPolUrl, this.tncUrl});

  Settings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    notifyKey = json['notify_key'];
    prvPolUrl = json['prv_pol_url'];
    tncUrl = json['tnc_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['notify_key'] = this.notifyKey;
    data['prv_pol_url'] = this.prvPolUrl;
    data['tnc_url'] = this.tncUrl;
    return data;
  }
}
