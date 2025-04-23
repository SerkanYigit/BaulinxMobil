class IlceList {
  int? id;
  String? value;
  String? name;
  String? idUavt;

  IlceList({this.id, this.value, this.name, this.idUavt});

  bool isEqual(IlceList model) {
    return this.value == model.value;
  }
}

List<IlceList> ilceList = [
  IlceList(id: 0, value: "610", name: "BAŞİSKELE", idUavt: "2058"),
  IlceList(id: 1, value: "611", name: "ÇAYIROVA", idUavt: "2059"),
  IlceList(id: 2, value: "612", name: "DARICA", idUavt: "2060"),
  IlceList(id: 3, value: "613", name: "DERİNCE", idUavt: "2030"),
  IlceList(id: 4, value: "614", name: "DİLOVASI", idUavt: "2061"),
  IlceList(id: 5, value: "615", name: "GEBZE", idUavt: "1338"),
  IlceList(id: 6, value: "616", name: "GÖLCÜK", idUavt: "1355"),
  IlceList(id: 7, value: "617", name: "İZMİT", idUavt: "2062"),
  IlceList(id: 8, value: "618", name: "KANDIRA", idUavt: "1430"),
  IlceList(id: 9, value: "619", name: "KARAMÜRSEL", idUavt: "1440"),
  IlceList(id: 10, value: "620", name: "KARTEPE", idUavt: "2063"),
  IlceList(id: 11, value: "621", name: "KÖRFEZ", idUavt: "1821"),
];
