/* import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io' as Io;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:mobil_ariza_flutter/core/riverpodlar/consumer.dart';
import 'package:mobil_ariza_flutter/core/riverpodlar/servisriverpod.dart';
import 'package:mobil_ariza_flutter/features/detaypages/detailpagewithdata/domain/muhtar_bilgileri.dart';
import 'package:mobil_ariza_flutter/features/detaypages/dropdownmodels/arizaNedeni_class.dart';
import 'package:mobil_ariza_flutter/features/detaypages/dropdownmodels/arizaTuru_class.dart';
import 'package:mobil_ariza_flutter/features/detaypages/dropdownmodels/cozumturu_class.dart';
import 'package:mobil_ariza_flutter/features/detaypages/dropdownmodels/muhtarlik_class.dart';
import 'package:mobil_ariza_flutter/features/detaypages/dropdownmodels/sonuc_turu_list.dart';
import 'package:mobil_ariza_flutter/features/detaypages/dropdownmodels/ustturu_class.dart';
import 'package:mobil_ariza_flutter/features/detaypages/talepdetay/data/kbsadresfromid.dart';
import 'package:mobil_ariza_flutter/features/detaypages/talepdetay/presentation/talep_detay_goster.dart';
import 'package:mobil_ariza_flutter/features/detaypages/talepdetay/presentation/talep_detay_kayit.dart';
import 'package:mobil_ariza_flutter/features/detaypages/widgets/personeldegistir.dart';
import 'package:mobil_ariza_flutter/features/detaypages/widgets/personelsecim.dart';
import 'package:mobil_ariza_flutter/features/detaypages/talepdetay/domain/talep_servisler.dart'
    as talepServisler;
import 'package:mobil_ariza_flutter/features/detaypages/dropdownmodels/durumu_class.dart';
import 'package:mobil_ariza_flutter/features/detaypages/dropdownmodels/ilcelist_class.dart';
import 'package:mobil_ariza_flutter/features/detaypages/widgets/showimage.dart';
import 'package:mobil_ariza_flutter/features/login/data/login_yetki_model.dart';
import 'package:mobil_ariza_flutter/models/personelist.dart';
import 'package:mobil_ariza_flutter/core/getfaultsrepository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobil_ariza_flutter/core/constants.dart' as sabitler;
import 'package:url_launcher/url_launcher.dart';
import '../../maintanenceform/mainform/bakim_formu.dart';
import '../../servismalzeme/servis_formucopy.dart';
import '../../../models/bakim/bakimilcebolge.dart';
import '../../../models/belgeler.dart';
import '../../../models/getmuhatap.dart';
import '../../../models/ariza_model.dart';
import '../../../core/widgets/detay_buttons.dart';
import 'package:mobil_ariza_flutter/core/ariza_services.dart' as servisler;
import 'package:mobil_ariza_flutter/core/bakimservices.dart' as bakimServisler;
import '../../tabs/main_tabs/presentation/tabsriverpod.dart';
import '../widgets/muhatapsecim.dart';
import 'package:mobil_ariza_flutter/features/detaypages/widgets/getimage.dart'
    as imagelar;
import 'package:mobil_ariza_flutter/features/detaypages/talepdetay/data/mahalle_model_kod.dart'
    as mahalleKodResult;

class DetailPage extends ConsumerStatefulWidget {
  final Arizam? arizam;
  // final String gelenArizaId;
  final String? userName;
  final String? ipAdresi;
  final List<GetMuhatap>? gelenMuhatap;
  List? gelenListFiltered = [];
  final bool isFiltered;
  final String? token;
  //  String arizaId =
  //   "46503"; //kamera 46503  , yazulum 46496 ,muhtarlık 46570
  // final String userName = "ifg";
  //final String idSbsKisi = "13652190";
  //final String idPbsKisi = "110947193";
  // final String idSisKullanici = "20000164";
  //final String ipAdresi = "192.168.1.1";
  //final String idKbsOrgut = "40001224";
  LoginYetkiModel yetkiler = LoginYetkiModel();
  final int isAtanan;
  DetailPage(
      {Key? key,
      this.token,
      this.arizam,
      //  @required this.gelenArizaId,
      required this.userName,
      this.ipAdresi,
      required this.yetkiler,
      this.gelenMuhatap,
      required this.isFiltered,
      this.gelenListFiltered,
      required this.isAtanan})
      : super(key: key);

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

enum buttonTypes {
  islemeAl,
  tamamla,
  kaydet,
  cogalt,
  baskaServiseAta,
}

class _DetailPageState extends ConsumerState<DetailPage>
    with SingleTickerProviderStateMixin {
  //List<Arizam> projectFiltered;
  Arizam? projectFiltered;
  bool isChanged = false;
  TextEditingController _idArizaController = TextEditingController();
  TextEditingController _bildirimTarihiController = TextEditingController();
  TextEditingController _baslatanKullaniciController = TextEditingController();
  TextEditingController _baslatanBirimController = TextEditingController();
  TextEditingController _ustTuruController = TextEditingController();
  TextEditingController _turuController = TextEditingController();
  TextEditingController _telefonController = TextEditingController();
  TextEditingController _gsmController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _aciklamaController = TextEditingController();
  TextEditingController sonucAciklamaController = TextEditingController();
  TextEditingController muhatapSecimController = TextEditingController();
  TextEditingController _yapiAdiController = TextEditingController();
  CarouselController buttonCarouselController = CarouselController();
  TextEditingController _muhtarBilgisiController = TextEditingController();

  final _muhtarlikDropDownProgKey =
      GlobalKey<DropdownSearchState<MuhtarlikList>>();
  final _cozumTuruDropDownProgKey =
      GlobalKey<DropdownSearchState<CozumTuruList>>();
  final _arizaNedeniDropDownProgKey =
      GlobalKey<DropdownSearchState<ArizaNedeniList>>();
  final _sonucTuruDropDownProgKey =
      GlobalKey<DropdownSearchState<ArizaNedeniList>>();
  final _arizaTuruDropDownProgKey =
      GlobalKey<DropdownSearchState<ArizaTuruList>>();
  List<mahalleKodResult.Result> mahalleKod = [];
  List<MuhtarlikList> muhtarlikList = [];
  List<CozumTuruList> cozumTuruList = [];
  List<ArizaNedeniList> arizaNedeniList = [];
  List<SonucTuruList> sonucTuruList = [];
  List<Belgeler> gelenBelgeler = [];
  List<GetPersonel> getPersonel = [];
  List<UstTuruList> roleGoreListe = [];
  List<ArizaTuruList> arizaTurList = [];
  List<IlceList> gelenIlce = [];
  List<DurumuList> gelenDurumu = [];
  List<Bakimilcebolge> bolgeApi = [];
  List<Image> resimListesi = [];
  List<String> sendingImageList = [];
  List<Bakimilcebolge> _bolgeApi = [];
  List<Bakimilcebolge> projectBolge = [];
  String? bolgeAdi;
  ImageUrlList? gelenBase64resim;
  List<String> urlList = [];
  LoginYetkiModel loginYetkiList = LoginYetkiModel();
  String? isAtananString;
  KbsAdresFromId? kbsAdresData = KbsAdresFromId();
  @override
  void initState() {
    projectFiltered = widget.arizam;
    bakimServisler.getBakimilcebolgeList().then((valueBolge) async {
      if (this.mounted) {
        setState(() {
          _bolgeApi.addAll(valueBolge);
          projectBolge = _bolgeApi;

          var ilceVerisi = projectBolge[0].result;
          ilceVerisi = ilceVerisi!.where((note) {
            var noteid = note.idAbsIlce.toString();
            return noteid.contains(projectFiltered!.idAbsIlce.toString());
          }).toList();

          if (ilceVerisi.isNotEmpty) {
            String bolgecik = ilceVerisi[0].bolgeAdi.toString();
            bolgeAdi = bolgecik.substring(9);
            debugPrint(" BÖLGE ADI   $bolgeAdi");
          } else {
            bolgeAdi = "";
          }
        });
      }
    });

    servisler.getPersonelListesi().then((value) async {
      if (this.mounted) {
        setState(() {
          getPersonel.addAll(value);
          debugPrint("Personel Listesi Sayısı : " +
              getPersonel[0].result!.length.toString());
          getPersonel.isNotEmpty
              ? isPersonelLoaded = true
              : isPersonelLoaded = false;
        });
      }
    });

    if (projectFiltered!.idKbsAdres != null) {
      talepServisler.TalepServisler()
          .getKbsAdresFromId(projectFiltered!.idKbsAdres.toString())
          .then((value) async {
        kbsAdresData = await value;
      });
    }

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    //roleGoreListe = servisler.ustTuruList;

    servisler.resimlerServisUrl(projectFiltered!.id).then((value) async {
      if (value != null) {
        if (!isImageAdded) {
          if (this.mounted) {
            //     str2 = "dolu";

            gelenBelgeler.addAll(value);

            if (gelenBelgeler[0].imageUrlList!.isEmpty) {
              debugPrint("Resim YOK");
            } else {
              //ImageUrlList gelenBase64resim;
              //     gelenBelgeler[0].imageUrlList[0];

              for (int i = 0; i < gelenBelgeler[0].imageUrlList!.length; i++) {
                gelenBase64resim = gelenBelgeler[0].imageUrlList![i];
                String urlTake = gelenBase64resim!.url!;
                urlList.add(urlTake);

                Image res = Image.network((gelenBase64resim!.url!));
                resimListesi.add(res);

                String _base64 = "";
                http.Response response = await http.get(
                  Uri.parse(gelenBase64resim!.url!),
                );

                if (mounted) {
                  setState(() {
                    _base64 = base64.encode(response.bodyBytes);
                    //  print(_base64);
                  });
                }

                sendingImageList.add(_base64);
              }

              //  debugPrint(sendingImageList.toString());
              // debugPrint(resimListesi.toString());
              isImageAdded = true;
              //print("GELEN DOSYA : " + gelenBase64dosya);
              // str2 = gelenBase64resim.replaceAll("\n", "");
              // print("içerdeyim");

              // resimcik = Image.memory(base64Decode(str2));
              // isload = true;
            }
          }
          setState(() {
            isImageAdded = true;
          });
        }
      }
    });

    switch (widget.isAtanan) {
      case 0:
        {
          isAtananString = "birimeAtanan";
        }
        break;
      case 1:
        {
          isAtananString = "banaAtanan";
        }
        break;
      case 2:
        {
          isAtananString = "takiptekiler";
        }
        break;
    }

    super.initState();

    // servisler.getMuhtarlikList("610", "1").then((value) async {
    //   if (value != null) {
    //     setState(() {
    //       muhtarlikList.addAll(value);
    //     });
    //   }
    //   print(muhtarlikList.runtimeType);
    // });
  }

  @override
  void dispose() {
    _aciklamaController.dispose();
    _baslatanBirimController.dispose();
    _baslatanKullaniciController.dispose();
    _bildirimTarihiController.dispose();
    _emailController.dispose();
    _gsmController.dispose();
    _idArizaController.dispose();
    muhatapSecimController.dispose();
    sonucAciklamaController.dispose();
    _telefonController.dispose();
    _turuController.dispose();
    _ustTuruController.dispose();
    _yapiAdiController.dispose();
    _muhtarBilgisiController.dispose();

    super.dispose();
  }

  MuhtarlikList? _selectedMuhtarlik;
  CozumTuruList? _selectedCozumTuru;
  ArizaNedeniList? _selectedArizaNedeni;
  SonucTuruList? _selectedSonucTuru;
  ArizaTuruList? _arizaTuruListe;
  UstTuruList? _ustTuruSelection;
  DurumuList? selectedDurumu;
  // DurumuList _selectedDurumu;
  bool isLoaded = false;
  bool isIlceChanged = false;
  bool isStopRefreshMuhtarlik = false;
  bool isStopRefreshCozumTuru = false;
  bool isStopCozumTuruListLoad = false;
  bool isStopRefreshArizaNedeni = false;
  bool isStopRefreshSonucTuru = false;
  bool isImageAdded = false;
  bool isPersonelLoaded = false;
  bool arizayiCogaltVisibility = false;
  bool isCallingPhone = false;
  bool isMuhtarlikVisibility = false;
  bool isArizaTurLoaded = false;
  bool isBakimVisibility = false;
  bool isButtonBeklemedeMi = false;
  bool isKayitBasariliMi = false;
  bool isIslemeAlindimi = false;
  bool isSonucAciklamaChanged = false;
  bool isYapiDetayTrue = false;
  GetMuhatap? secilenMuhatap;
  MuhtarBilgisi? _muhtarBilgisi;
  Animation<double>? _animation;
  late AnimationController _animationController;
  StateSetter? _setStateModel;
  String? _durumu;
  String? durumuKayit;
  String? sonucIdKayit;
  String? sonucAciklamaKayit;
  String? ilceKayit;
  String? muhtarlikKayitId;
  String? cozumTuruIdKayit;
  String? arizaNedeniIdKayit;
  String? pbsPersonelBildirenKayit;
  String? bitisTarihiKayit;
  String? onayKayit;
  String? idPersonelOnaylayanKayit,
      idPbsPersonelIslemYapanKayit,
      idPbsPersonelIslemYapanIkiKayit,
      idPbsPersonelIslemYapanUcKayit,
      idPbsPersonelIslemYapanDortKayit,
      gelenUstTur,
      gelenArizaTuruId,
      gidenUstTur,
      gidenArizaTuru,
      _ilceDegisim,
      bildirimTarihiNowKayit,
      refurbishedTel,
      idMahalleUavt;

  void arizaTuruGetir(String ustTuruSecim) {
    servisler.getArizaTurList("$ustTuruSecim").then((value) {
      // arizaTurList = [];

      if (this.mounted) {
        setState(() {
          arizaTurList.addAll(value!);
          debugPrint("ARIZA TUR LİST UZUNLUĞU ${arizaTurList.length}");

          _arizaTuruDropDownProgKey.currentState!.setState(() {});
        });
      }
    });
  }

  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var extend = false;

  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);
  var speedDialDirection = SpeedDialDirection.up;
  var buttonSize = const Size(68.0, 68.0);
  var childrenButtonSize = const Size(56.0, 56.0);
  var selectedfABLocation = FloatingActionButtonLocation.endDocked;

  void alanDoldur() {
    if (projectFiltered != null) {
      sonucAciklamaController.text = projectFiltered!.sonucAciklama ?? "";
      if (sonucAciklamaController.text != null &&
          sonucAciklamaController.text != "") {
        sonucAciklamaKayit = sonucAciklamaController.text;
      }
    }
  }

  Widget build(BuildContext context) {
    debugPrint(" WIDGET ARIZAM${widget.arizam}");
    //  String _selectedItem = "İlçe";

    // //   var sonuc;
    // print("DATA YÜKLENDİ");
    // var noteid;
    // projectFiltered = data;
    // projectFiltered = projectFiltered.where((note) {
    //   noteid = note.id.toString();
    //   return noteid.contains("${widget.gelenArizaId}");
    // }).toList();

    if (projectFiltered == null) {
      CircularProgressIndicator();
    } else {
      selectedDurumu != null
          ? _durumu = selectedDurumu!.name
          : _durumu = projectFiltered!.durumu;

      projectFiltered != null ? isLoaded = true : isLoaded = false;
      if (_durumu == 'Beklemede') {
        setState(() {
          debugPrint(_durumu);
          isButtonBeklemedeMi = true;

          debugPrint(" isButtonBeklemediMi: " + isButtonBeklemedeMi.toString());
        });
      } else {
        if (this.mounted) {
          setState(() {
            debugPrint(_durumu);
            isButtonBeklemedeMi = false;

            debugPrint(
                " isButtonBeklemediMi: " + isButtonBeklemedeMi.toString());
          });
        }
      }

      // _durumu == 'Beklemede'
      //     ? floatingButtons.add(Bubble(
      //         title: "İŞLEME AL",
      //         iconColor: Colors.white,
      //         bubbleColor: Colors.blue,
      //         icon: Icons.settings,
      //         titleStyle: TextStyle(fontSize: 16, color: Colors.white),
      //         onPress: () {
      //           _animationController.isCompleted;
      //           islemeAlButton(
      //             _aciklamaController,
      //             context,
      //           );
      //         },
      //       ))
      //     : null;

      _idArizaController.text = projectFiltered!.id.toString();
      _bildirimTarihiController.text = projectFiltered!.bildirimTarihi!;
      _baslatanKullaniciController.text = projectFiltered!.pbsPersonelBildiren;
      _baslatanBirimController.text = projectFiltered!.pbsPersonelBildirenOrgut;
      _ustTuruController.text = projectFiltered!.arizaUstTuru!;
      gelenUstTur = projectFiltered!.arizaUstTuru;
      _turuController.text = projectFiltered!.arizaTuru!;
      _telefonController.text = projectFiltered!.telefon ?? "";
      _gsmController.text = projectFiltered!.gsm ?? "";

      if (kbsAdresData!.result != null) {
        if (kbsAdresData!.result!.isNotEmpty) {
          isYapiDetayTrue = true;
          _yapiAdiController.text = kbsAdresData!.result![0].mevkii ?? "";
        }
      }

      //!
      //  _yapiAdiController.text = projectFiltered!.idKbsAdres ?? "";
      if (projectFiltered!.gsm.toString().length > 9) {
        isCallingPhone = true;
      }

      _emailController.text =
          projectFiltered!.email ?? projectFiltered!.alternatifEmail ?? "";
      _aciklamaController.text = projectFiltered!.aciklama!;

      if (!isSonucAciklamaChanged) {
        alanDoldur();
      }

      // sonucAciklamaController.text = projectFiltered.sonucAciklama;
      // if (sonucAciklamaController.text != null &&
      //     sonucAciklamaController.text != "") {
      //   sonucAciklamaKayit = sonucAciklamaController.text;
      // }

      // sonucAciklamaController.text = "denenemedir";

      projectFiltered!.durumu != 'Beklemede'
          ? isChanged = true
          : isChanged = false;

      projectFiltered!.arizaUstTuru == "BILGI_ISLEM_KAMERA"
          ? isBakimVisibility = true
          : isBakimVisibility = false;

      projectFiltered!.arizaUstTuru == "MUHTARLIK"
          ? isMuhtarlikVisibility = true
          : isMuhtarlikVisibility = false;

      if (gelenDurumu.isEmpty) {
        gelenDurumu = durumList.where((projem) {
          var noteid = projem.name;
          return noteid!.contains(projectFiltered!.durumu!);
        }).toList();
        durumuKayit = gelenDurumu[0].kayitName;
      }

      //! Kullanıcıdan red yapıp kayıt ettiğimde Valid ,,value range is empty hatası veriyor
      if (!isIslemeAlindimi) {
        selectedDurumu = gelenDurumu[0];
      }

      gelenIlce = ilceList.where((projem) {
        var noteid = projem.value.toString();
        return noteid.contains(projectFiltered!.idAbsIlce.toString());
      }).toList();

      void muhtarlikGetir() {
        if (!isStopRefreshMuhtarlik) {
          var note2;
          if (projectFiltered!.idSbsKurumMuhtarlik != null) {
            servisler
                .getMuhtarlikList(
                    "${projectFiltered!.idAbsIlce.toString()}", "1")
                .then((value) {
              bool isThere = false;
              // for (var i = 0; i < value.length; i++) {
              //   isThere =
              //       value.contains(projectFiltered[0].idSbsKurumMuhtarlik);
              // }

              for (var i = 0; i < value.length; i++) {
                if (value[i].sbsMuhatapId ==
                    projectFiltered!.idSbsKurumMuhtarlik) {
                  isThere = true;
                }
              }

              debugPrint(isThere.toString());
              if (isThere) {
                note2 = value.firstWhere((element) =>
                    element.sbsMuhatapId ==
                    projectFiltered!.idSbsKurumMuhtarlik);
                debugPrint(note2.runtimeType.toString());
                _selectedMuhtarlik = note2;
              }

              if (this.mounted) {
                talepServisler.TalepServisler()
                    .getMahalleUavtKod(
                        _selectedMuhtarlik!.sbsMuhatapId.toString(),
                        projectFiltered!.idAbsIlce.toString())
                    .then((value) {
                  mahalleKod.addAll(value!);
                  idMahalleUavt = mahalleKod[0].uavt_kodu.toString();
                  servisler
                      .getMuhtarBilgis(idMahalleUavt.toString())
                      .then((value) {
                    _muhtarBilgisi = value;
                    print(value);
                    _muhtarBilgisiController.text = value.muhtarAdiSoyadi;
                  });
                });

                setState(() {
                  _selectedMuhtarlik != null
                      ? muhatapSecimController.text = note2.unvani
                      : muhatapSecimController.text =
                          ""; //! NAPACAZ burada ,normalde null vermiştim
                  //! buraya api den veri getirip isim soyisim ve tel alacaksın
                });
              }
            });
          } else
            _selectedMuhtarlik = null;
          isStopRefreshMuhtarlik = true;
        }
      }

      muhtarlikGetir();

      //  _getMuhatapList(_ilce, _idFaaliyet).then((value) {
      //       if (muhatapList != null) {
      //         if (gelenVeri.idSbsKurumMuhtarlik != null) {
      //           muhatapSorgu = muhatapList.where((note) {
      //             var noteid = note['sbsMuhatapId'].toString();
      //             return noteid
      //                 .contains(gelenVeri.idSbsKurumMuhtarlik.toString());
      //           }).toList();
      //           debugPrint("MUHATAP SORGU = $muhatapSorgu");
      //           if (muhatapSorgu.isEmpty) {
      //             _muhtarlik = null;

      //             // _muhtarlik == "null"
      //             //     ? gelenMuhtarlikId = null
      //             //     : gelenMuhtarlikId = _muhtarlik;
      //           } else {
      //             _muhtarlik = gelenVeri.idSbsKurumMuhtarlik.toString();
      //           }
      //         }
      //       }
      //     });
      if (cozumTuruList.isEmpty) {
        servisler
            .getCozumList("${projectFiltered!.arizaUstTuru}")
            .then((value) async {
          cozumTuruList.addAll(value);
        });
      }
      void cozumGetir() {
        if (!isStopRefreshCozumTuru) {
          if (projectFiltered!.cozumTuruId != null) {
            servisler
                .getCozumList("${projectFiltered!.arizaUstTuru}")
                .then((value) {
              var note = value.firstWhere(
                  (element) => element.id == projectFiltered!.cozumTuruId);
              // debugPrint(note.toString());

              if (this.mounted) {
                setState(() {
                  _selectedCozumTuru = note;
                });
              }
            });
          }
          isStopRefreshCozumTuru = true;
        }
      }

      cozumGetir();

      void arizaNedeniGetir() {
        if (!isStopRefreshArizaNedeni) {
          if (projectFiltered!.arizaNedeniId != null) {
            servisler
                .getArizaNedeniList("${projectFiltered!.cozumTuruId}")
                .then((value) {
              var note = value.firstWhere(
                  (element) => element.id == projectFiltered!.arizaNedeniId);
              // debugPrint(note.toString());

              if (this.mounted) {
                setState(() {
                  _selectedArizaNedeni = note;
                });
              }
            });
          }
          isStopRefreshArizaNedeni = true;
        }
      }

      arizaNedeniGetir();

      void sonucTuruGetir() {
        if (!isStopRefreshSonucTuru) {
          if (projectFiltered!.sonucId != null) {
            servisler.getSonucTuruList().then((value) {
              var note = value.firstWhere(
                  (element) => element.id == projectFiltered!.sonucId);
              //  debugPrint(note.toString());
              sonucTuruList.addAll(value);
              if (this.mounted) {
                setState(() {
                  _selectedSonucTuru = note;
                });
              }
            });
          } else {
            servisler.getSonucTuruList().then((value) {
              sonucTuruList.addAll(value);
            });
          }
          isStopRefreshSonucTuru = true;
        }
      }

      sonucTuruGetir();

      // void resimlerGetir() {

      //   servisler.resimlerServisUrl(projectFiltered.id).then((value) async {
      //     if (value != null) {
      //       if (!isImageAdded) {
      //         if (this.mounted) {
      //           //     str2 = "dolu";

      //           gelenBelgeler.addAll(value);

      //           if (gelenBelgeler[0].imageUrlList.isEmpty) {
      //             debugPrint("Resim YOK");
      //           } else {
      //             ImageUrlList gelenBase64resim;
      //             //     gelenBelgeler[0].imageUrlList[0];

      //             for (int i = 0;
      //                 i < gelenBelgeler[0].imageUrlList.length;
      //                 i++) {
      //               gelenBase64resim = gelenBelgeler[0].imageUrlList[i];

      //               Image res = Image.network((gelenBase64resim.url));
      //               resimListesi.add(res);
      //             }

      //             for (int i = 0;
      //                 i < gelenBelgeler[0].imageUrlList.length;
      //                 i++) {
      //               String _base64;
      //               http.Response response = await http.get(
      //                 Uri.parse(gelenBase64resim.url),
      //               );

      //               if (mounted) {
      //                 setState(() {
      //                   _base64 = base64.encode(response.bodyBytes);
      //                   //  print(_base64);
      //                 });
      //               }

      //               sendingImageList.add(_base64);
      //             }

      //             //  debugPrint(sendingImageList.toString());
      //             // debugPrint(resimListesi.toString());
      //             isImageAdded = true;
      //             //print("GELEN DOSYA : " + gelenBase64dosya);
      //             // str2 = gelenBase64resim.replaceAll("\n", "");
      //             // print("içerdeyim");

      //             // resimcik = Image.memory(base64Decode(str2));
      //             // isload = true;
      //           }
      //         }
      //         setState(() {
      //           isImageAdded = true;
      //         });
      //       }
      //     }
      //   });

      // }

      // if (!isImageAdded) {
      //   resimlerGetir();
      // }
//? ************************
      // void belgelerGetir() {
      //   servisler
      //       .belgelerServis(int.parse(projectFiltered.id.toString()))
      //       .then((value) async {
      //     if (value != null) {
      //       if (!isImageAdded) {
      //         if (this.mounted) {
      //           setState(() {
      //             //     str2 = "dolu";

      //             gelenBelgeler.addAll(value);

      //             if (gelenBelgeler[0].base64ImageList.isEmpty) {
      //               debugPrint("Resim YOK");
      //             } else {
      //               String gelenBase64resim =
      //                   gelenBelgeler[0].base64ImageList[0];

      //               for (int i = 0;
      //                   i < gelenBelgeler[0].imageUrlList.length;
      //                   i++) {
      //                 gelenBase64resim = gelenBelgeler[0].base64ImageList[i];
      //                 Image res = Image.memory(
      //                     base64Decode(gelenBase64resim.replaceAll("\n", "")));
      //                 sendingImageList.add(gelenBase64resim);
      //                 resimListesi.add(res);
      //               }
      //               debugPrint(sendingImageList.toString());
      //               debugPrint(resimListesi.toString());
      //               isImageAdded = true;
      //               //print("GELEN DOSYA : " + gelenBase64dosya);
      //               // str2 = gelenBase64resim.replaceAll("\n", "");
      //               // print("içerdeyim");

      //               // resimcik = Image.memory(base64Decode(str2));
      //               // isload = true;
      //             }
      //           });
      //         }
      //         isImageAdded = true;
      //         debugPrint("isImageAdded $isImageAdded");
      //       }
      //       debugPrint("isImageAdded $isImageAdded");
      //     }
      //   });
      // }

      // if (!isImageAdded) {
      //   belgelerGetir();
      // }

      var bolgeIlceFiltered = bolgeApi;
      bolgeIlceFiltered = bolgeIlceFiltered.where((note) {
        var noteid = note.result.toString();
        return noteid.contains(projectFiltered!.idAbsIlce.toString());
      }).toList();
    }

    // if (bolgeIlceFiltered.isNotEmpty) {
    //   String bolgecik = bolgeIlceFiltered[0].result.bolgeAdi.toString();
    //   bolgeAdi = bolgecik.substring(9);
    //   debugPrint(bolgeAdi);
    // } else {
    //   bolgeAdi = "";
    // }

    // if (!isArizaTurLoaded) {
    //   arizaTuruGetir(projectFiltered[0].arizaUstTuru);
    //   arizaTurList.isNotEmpty
    //       ? isArizaTurLoaded = true
    //       : isArizaTurLoaded = false;
    // }

    // ref.listen(arizaListesiProvider("${widget.userName}"),
    //     (AsyncValue previousCount, AsyncValue newCount) {
    //   print('The counter changed $newCount');
    // });

    final List<SpeedDialChild> floatingButtons = [];

    void menuyuYukle() {
      //? İŞLEME AL Button
      isButtonBeklemedeMi
          ? floatingButtons.add(
              SpeedDialChild(
                visible: isButtonBeklemedeMi,
                child: Icon(Icons.assessment_outlined),
                backgroundColor: Color.fromARGB(255, 46, 159, 50),
                foregroundColor: Colors.white,
                // label: 'İŞLEME AL',
                // labelBackgroundColor: Colors.blue,
                // labelStyle: TextStyle(color: Colors.white),
                labelWidget: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 50, 136, 162),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width / 2,
                    // color: Color.fromARGB(255, 204, 123, 36),
                    child: Text(
                      "İşleme Al",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )),

                onTap: () {
                  debugPrint("İŞLEME AL ");
                  islemeAlButton(
                    _aciklamaController,
                    context,
                  );

                  // showDialog(
                  //     barrierDismissible: false,
                  //     context: context,
                  //     barrierColor: Colors.transparent,
                  //     builder: (BuildContext ctx) {
                  //       return AlertDialog(
                  //         actionsAlignment: MainAxisAlignment.center,
                  //         elevation: 10,
                  //         title: const Text('Lütfen Bekleyiniz...'),
                  //         content: SizedBox(
                  //           height: 50,
                  //           width: 50,
                  //           child: Center(
                  //             child: CircularProgressIndicator(),
                  //           ),
                  //         ),
                  //         // actions: [
                  //         //   TextButton(
                  //         //     onPressed: () {
                  //         //       Navigator.pop(ctx);
                  //         //     },
                  //         //     child: const Text('Kapat'),
                  //         //   )
                  //         // ],
                  //       );
                  //     });
                },
              ),
            )
          : null;

      //? BAŞKASINA ATA
      floatingButtons.add(
        SpeedDialChild(
          child: Icon(Icons.redo),

          backgroundColor: Color.fromARGB(255, 204, 123, 36),
          foregroundColor: Colors.white,

          labelWidget: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 204, 123, 36),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width / 2,
              // color: Color.fromARGB(255, 204, 123, 36),
              child: Text(
                "Başka Servise Ata",
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),

          //label: 'BAŞKASINA ATA',
          //labelBackgroundColor: Color.fromARGB(255, 204, 123, 36),
          //labelStyle: TextStyle(color: Colors.white),
          onTap: () {
            arizayiCogaltVisibility = false;
            //  arizaTuruGetir(projectFiltered[0].arizaUstTuru);
            baskaServiseAtaButton(
              //   projectFiltered[0].arizaUstTuru,
              context,
              // projectFiltered[0].idBatArizaTuru.toString(),
              //   isMuhtarlikVisibility,
              true, arizayiCogaltVisibility,
            );
          },
        ),
      );
      //? KAYDET
      floatingButtons.add(
        SpeedDialChild(
          child: Icon(Icons.save),
          backgroundColor: Color.fromARGB(255, 163, 14, 14),
          foregroundColor: Colors.white,
          // label: 'KAYDET',
          // labelBackgroundColor: Color.fromARGB(255, 163, 14, 14),
          // labelStyle: TextStyle(color: Colors.white),
          labelWidget: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 163, 14, 14),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width / 2,
              // color: Color.fromARGB(255, 204, 123, 36),
              child: Text(
                "Kaydet",
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),

          visible: true,
          onTap: () {
//             List<String> imageStringsa =
//                 resimListesi.map((image) => image.toString()).toList();

//             print(imageStringsa);

// // List<Image> images123 = [Image.asset('assets/image1.png'), Image.asset('assets/image2.png'), Image.asset('assets/image3.png')];

//             List<String> imageStrings123 = [];

//             for (Image image in resimListesi) {
//               final ByteData imageData = image.toByteData;
//               if (imageData != null) {
//                 final Uint8List bytes = imageData.buffer.asUint8List();
//                 final String base64String = base64Encode(bytes);
//                 imageStrings123.add(base64String);
//               }
//             }

// // print(imageStrings123);

            kaydetButton(_durumu);
          },
        ),
      );
      //? ARIZAYI ÇOĞALT
      floatingButtons.add(
        SpeedDialChild(
          child: Icon(Icons.copy),
          backgroundColor: Color.fromARGB(255, 14, 19, 163),
          foregroundColor: Colors.white,
          // label: 'ARIZAYI ÇOĞALT',
          // labelBackgroundColor: Color.fromARGB(255, 14, 19, 163),
          // labelStyle: TextStyle(color: Colors.white),
          labelWidget: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 14, 19, 163),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width / 2,
              // color: Color.fromARGB(255, 204, 123, 36),
              child: Text(
                "Arızayı Çoğalt",
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),

          onTap: () {
            arizayiCogaltVisibility = true;
            baskaServiseAtaButton(
                context, isMuhtarlikVisibility, arizayiCogaltVisibility);
          },
        ),
      );
      //? İŞLEMLERİ TAMAMLA
      floatingButtons.add(
        SpeedDialChild(
          visible: !isButtonBeklemedeMi,
          child: Icon(Icons.done),
          backgroundColor: Color.fromARGB(255, 39, 137, 49),
          foregroundColor: Colors.white,
          // label: 'İŞLEMİ TAMAMLA',
          // labelBackgroundColor: Color.fromARGB(255, 39, 137, 49),
          // labelStyle: TextStyle(color: Colors.white),
          labelWidget: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 39, 137, 49),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width / 2,
              // color: Color.fromARGB(255, 204, 123, 36),
              child: Text(
                "İşlemleri Tamamla",
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),

          onTap: () {
            islemleriTamamlaButton(sonucAciklamaKayit, context, _durumu);
          },
        ),
      );
      //? BAKIM FORMU

      (!isButtonBeklemedeMi && isBakimVisibility)
          ? floatingButtons.add(
              SpeedDialChild(
                child: Icon(Icons.report_problem_outlined),
                backgroundColor: Color.fromARGB(255, 50, 136, 162),
                foregroundColor: Colors.white,
                // label: 'BAKIM FORMU',
                // labelBackgroundColor: Color.fromARGB(255, 204, 123, 36),
                // labelStyle: TextStyle(color: Colors.white),
                labelWidget: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 50, 136, 162),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width / 2,
                    // color: Color.fromARGB(255, 204, 123, 36),
                    child: Text(
                      "Bakım Formu",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )),

                visible: !isButtonBeklemedeMi,
                onTap: () {
                  debugPrint("bakim formu");
                  bakimFormuButton(_durumu, context, _ilceDegisim);
                },
              ),
            )
          : null;

      //? SERVİS FORMU

      (!isButtonBeklemedeMi && isMuhtarlikVisibility == true)
          ? floatingButtons.add(
              SpeedDialChild(
                child: Icon(Icons.report),
                backgroundColor: Color.fromARGB(255, 50, 136, 162),
                foregroundColor: Colors.white,
                // label: 'SERVİS FORMU',
                // labelBackgroundColor: Color.fromARGB(255, 204, 123, 36),
                // labelStyle: TextStyle(color: Colors.white),
                labelWidget: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 50, 136, 162),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width / 2,
                    // color: Color.fromARGB(255, 204, 123, 36),
                    child: Text(
                      "Servis Formu",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )),

                visible: !isButtonBeklemedeMi,
                onTap: () {
                  servisFormuButton(_durumu!, context, _ilceDegisim ?? "null");
                },
              ),
            )
          : null;
    }

    menuyuYukle();

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        //Init Floating Action Bubble

        floatingActionButton: SpeedDial(
          backgroundColor: Colors.amber[700],
          // animatedIcon: AnimatedIcons.menu_close,
          // animatedIconTheme: IconThemeData(size: 22.0),
          // / This is ignored if animatedIcon is non null
          // child: Text("open"),
          // activeChild: Text("close"),
          icon: Icons.menu,
          activeIcon: Icons.close,
          spacing: 3,
          // mini: mini,
          openCloseDial: isDialOpen,
          //  childPadding: const EdgeInsets.all(5),
          // spaceBetweenChildren: 4,
          dialRoot: customDialRoot
              ? (ctx, open, toggleChildren) {
                  return ElevatedButton(
                    onPressed: toggleChildren,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 161, 67, 13),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 18),
                    ),
                    child: const Text(
                      "Custom Dial Root",
                      style: TextStyle(fontSize: 17),
                    ),
                  );
                }
              : null,
          buttonSize:
              buttonSize, // it's the SpeedDial size which defaults to 56 itself
          // iconTheme: IconThemeData(size: 22),
          //label: extend
          //      ? const Text("Open")
          //    : null, // The label of the main button.
          /// The active label of the main button, Defaults to label if not specified.
          //activeLabel: extend ? const Text("Close") : null,

          /// Transition Builder between label and activeLabel, defaults to FadeTransition.
          // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
          /// The below button size defaults to 56 itself, its the SpeedDial childrens size
          childrenButtonSize: childrenButtonSize,
          visible: visible,
          direction: speedDialDirection,
          switchLabelPosition: switchLabelPosition,

          /// If true user is forced to close dial manually
          closeManually: closeManually,

          /// If false, backgroundOverlay will not be rendered.
          renderOverlay: renderOverlay,
          // overlayColor: Colors.black,
          // overlayOpacity: 0.5,
          onOpen: () => debugPrint('OPENING DIAL DETAY EKRANI'),
          onClose: () => debugPrint('DIAL CLOSED'),
          useRotationAnimation: useRAnimation,
          tooltip: 'Open Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          // foregroundColor: Colors.black,
          // backgroundColor: Colors.white,
          // activeForegroundColor: Colors.red,
          // activeBackgroundColor: Colors.blue,
          elevation: 8.0,
          animationCurve: Curves.elasticInOut,
          isOpenOnStart: false,
          shape: customDialRoot
              ? const RoundedRectangleBorder()
              : const StadiumBorder(),
          // childMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          children: floatingButtons,
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            PopupMenuButton(
                icon: Icon(Icons.add_to_photos_rounded,
                    color: Color.fromARGB(255, 255, 255, 255)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.add_a_photo),
                        title: Text('Kamera'),
                        onTap: () {
                          // _imageCameraFile = null;
                          // _imageGalleryFile = null;
                          // getCamera();

                          imagelar.GetImage().getCameraImage().then((value) {
                            setState(() {
                              sendingImageList.add(value);
                              //   debugPrint(_imageGalleryFile);
                              debugPrint(base64.toString());
                              Image res = Image.memory(
                                  base64Decode(value.replaceAll("\n", "")));

                              resimListesi.add(res);
                            });
                          });

                          Navigator.pop(context);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.add_photo_alternate_outlined),
                        title: Text('Galeri'),
                        onTap: () {
                          // _imageCameraFile = null;
                          // _imageGalleryFile = null;

                          imagelar.GetImage().getGalleryImage().then((value) {
                            setState(() {
                              sendingImageList.add(value);
                              //   debugPrint(_imageGalleryFile);
                              debugPrint(base64.toString());
                              Image res = Image.memory(
                                  base64Decode(value.replaceAll("\n", "")));

                              resimListesi.add(res);

                              //  resimListesi.add(value);
                            });
                          });

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ];
                })
          ],
          backgroundColor: Color.fromARGB(255, 70, 135, 209),
          title: Text("ARIZA DETAY ${projectFiltered!.id}"),
        ),
        body: isLoaded
            ? Container(
                alignment: Alignment.topLeft,
                color: sabitler.kMainColor,
                //Color(0xFF73AEF5),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: [
                          //? GELEN VERİLER
                          Card(
                            color: sabitler.kMainColor,
                            shadowColor: Color.fromARGB(255, 212, 77, 122),
                            // color: Colors.white,
                            elevation: 50.0,
                            shape: new RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color.fromARGB(255, 196, 193, 184)),
                              borderRadius: new BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: MyDetayTextField3(
                                            readOnlyTxt: true,
                                            labelTxt: "Arıza Talep No",
                                            controllerTxt: _idArizaController,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: MyDetayTextField3(
                                            readOnlyTxt: true,
                                            labelTxt: "Bildirim Tarihi",
                                            controllerTxt:
                                                _bildirimTarihiController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Padding(
                                  //   padding: const EdgeInsets.all(3.0),
                                  //   child: Divider(
                                  //     thickness: 2,
                                  //     color: Color.fromARGB(255, 152, 147, 147),
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: MyDetayTextField3(
                                            suffixIcon: isBakimVisibility ==
                                                        true &&
                                                    isMuhtarlikVisibility ==
                                                        false
                                                ? !isPersonelLoaded
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  181,
                                                                  204,
                                                                  62),
                                                          color: Color.fromARGB(
                                                              255,
                                                              201,
                                                              92,
                                                              101),
                                                        ),
                                                      )
                                                    : IconButton(
                                                        onPressed: () async {
                                                          // _durumu == 'Beklemede'
                                                          //   ? kayitbos(
                                                          //       () {},
                                                          //       "TAMAM",
                                                          //       DialogType.error,
                                                          //       "Önce İşleme Almalısınız.",
                                                          //       Colors.red,
                                                          //       "Hata",
                                                          //       null,
                                                          //       context)
                                                          //   :

                                                          setState(() {
                                                            evetHayirAlert(
                                                                () async {
                                                              debugPrint(
                                                                  "kullanıcı değiştir butonuna basıldı");

                                                              var ddd =
                                                                  await Navigator.of(
                                                                          context)
                                                                      .push(
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          PersonelDegistir(
                                                                    gelenListe2:
                                                                        getPersonel,
                                                                    idAriza2:
                                                                        _idArizaController
                                                                            .text,
                                                                    userId2: widget
                                                                        .yetkiler
                                                                        .idKullanici,
                                                                  ),
                                                                ),
                                                              );
                                                              debugPrint(ddd
                                                                  .toString());
                                                              // ref.invalidate(
                                                              //     getFaultsProvider(
                                                              //         username:
                                                              //             widget
                                                              //                 .userName!));
                                                            },
                                                                () {},
                                                                "EVET",
                                                                "HAYIR",
                                                                DialogType
                                                                    .warning,
                                                                "Başlatan Kullanıcıyı değiştirmek istediğinize Emin misiniz?",
                                                                Colors.red,
                                                                Colors.green,
                                                                "Uyarı",
                                                                null,
                                                                context);
                                                            // ref.invalidate(
                                                            //     arizaListesiProvider("ifg"));
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons
                                                              .account_circle_sharp,
                                                          color: Colors.amber,
                                                        ),
                                                      )
                                                : Text(""),
                                            readOnlyTxt: true,
                                            labelTxt: "Başlatan Kullanıcı",
                                            controllerTxt:
                                                _baslatanKullaniciController,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: MyDetayTextField3(
                                            readOnlyTxt: true,
                                            labelTxt: "Başlatan Birim",
                                            controllerTxt:
                                                _baslatanBirimController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(3.0),
                                  //   child: Divider(
                                  //     thickness: 2,
                                  //     color: Color.fromARGB(255, 152, 147, 147),
                                  //   ),
                                  // ),
//? ARIZA UST TURU - ARIZA TURU
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: MyDetayTextField3(
                                            readOnlyTxt: true,
                                            labelTxt: "Arıza Üst Türü",
                                            controllerTxt: _ustTuruController,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: MyDetayTextField3(
                                            readOnlyTxt: true,
                                            labelTxt: "Arıza Türü",
                                            controllerTxt: _turuController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Padding(
                                  //   padding: const EdgeInsets.all(3.0),
                                  //   child: Divider(
                                  //     thickness: 2,
                                  //     color: Color.fromARGB(255, 152, 147, 147),
                                  //   ),
                                  // ),
//? DAHİLİ TELEFON - GSM
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: MyDetayTextField3(
                                            readOnlyTxt: true,
                                            labelTxt: "Dahili Telefon No",
                                            controllerTxt: _telefonController,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: MyDetayTextField3(
                                            suffixIcon: Visibility(
                                              visible: isCallingPhone,
                                              child: IconButton(
                                                onPressed: () async {
                                                  debugPrint(
                                                      projectFiltered!.gsm[0]);
                                                  String refurbishedTel = "0" +
                                                      projectFiltered!.gsm;
                                                  debugPrint(refurbishedTel);

                                                  if (await canLaunchUrl(
                                                    Uri(
                                                      scheme: 'tel',
                                                      path: refurbishedTel,
                                                    ),
                                                  )) {
                                                    await launchUrl(
                                                      Uri(
                                                        scheme: 'tel',
                                                        path: refurbishedTel,
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Numara çevrilemedi. $refurbishedTel')));
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.phone,
                                                  color: Color.fromARGB(
                                                      255, 61, 232, 109),
                                                ),
                                              ),
                                            ),
                                            readOnlyTxt: true,
                                            labelTxt: "GSM No",
                                            controllerTxt: _gsmController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(3.0),
                                  //   child: Divider(
                                  //     thickness: 2,
                                  //     color: Color.fromARGB(255, 152, 147, 147),
                                  //   ),
                                  // ),
                                  //? EMAIL
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MyDetayTextField3(
                                      readOnlyTxt: true,
                                      labelTxt: "E-mail",
                                      controllerTxt: _emailController,
                                    ),
                                  ),
                                  //? AÇIKLAMA
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MyDetayTextField3(
                                      maxLinesTxt: null,
                                      readOnlyTxt: true,
                                      labelTxt: "Açıklama",
                                      controllerTxt: _aciklamaController,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //? DURUMU - İLÇE LİSTESİ - MUHTARLIK - MUHATap SEÇİM
                          Card(
                            color: sabitler.kMainColor,
                            shadowColor: Color.fromARGB(255, 212, 77, 122),
                            // color: Colors.white,
                            elevation: 50.0,
                            shape: new RoundedRectangleBorder(
                              side: BorderSide(color: Colors.amber),
                              borderRadius: new BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                children: [
                                  //? DURUMU
                                  //  DurumuDropDownWidget(index: gelenDurumu[0].id),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: 
                                    

                                    DropdownSearch<DurumuList>(
                                      enabled: selectedDurumu != durumList[0]
                                          ? true
                                          : false,
                                      popupProps: PopupProps.bottomSheet(
                                        bottomSheetProps: BottomSheetProps(
                                          backgroundColor:
                                              Color.fromARGB(255, 70, 135, 209),
                                        ),
                                        itemBuilder: (
                                          BuildContext context,
                                          DurumuList item,
                                          bool isSelected,
                                        ) {
                                          return Container(
                                            // color: Color.fromARGB(255, 184, 125, 22),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: !isSelected
                                                ? null
                                                : BoxDecoration(
                                                    border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Color.fromARGB(
                                                        255,
                                                        202,
                                                        202,
                                                        198), //yazının arka rengi
                                                  ),
                                            child: ListTile(
                                              //tileColor: Color.fromARGB(255, 52, 138, 230),
                                              selected: isSelected,
                                              title: Center(
                                                  child: Text(
                                                item.name ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              )),
                                            ),
                                          );
                                        },
                                        showSelectedItems: true,
                                        emptyBuilder: (BuildContext context,
                                            searchEntry) {
                                          return Container(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Listede Veri Bulunamadı.",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (() =>
                                                        Navigator.of(context)
                                                            .pop()),
                                                    child: Text("Kapat"),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        // disabledItemFn: (String s) =>
                                        //     s.startsWith('I'),
                                      ),
                                      itemAsString: (item) => item.name!,
                                      items: durumList,
                                      compareFn: (i, s) => i.isEqual(s),
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        textAlign: TextAlign.center,
                                        baseStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          floatingLabelAlignment:
                                              FloatingLabelAlignment.start,

                                          floatingLabelStyle: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),

                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.pink,
                                            ),
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Color.fromARGB(
                                                  255, 190, 195, 193),
                                            ),
                                          ),

                                          //   suffixIcon: Icon(Icons.abc),
                                          //    icon: Icon(Icons.extension),
                                          //   disabledBorder: InputBorder.none,
                                          labelText: "Durumu",
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Color.fromARGB(
                                                  255, 21, 20, 20)),
                                        ),
                                      ),
                                      onChanged: ((value) {
                                        debugPrint(value!.name);
                                        debugPrint(value.value);

                                        setState(() {
                                          durumuKayit = value.kayitName;
                                          selectedDurumu = value;
                                        });
                                      }),
                                      selectedItem: selectedDurumu != null
                                          ? selectedDurumu
                                          : gelenDurumu[0],
                                    ),
                           
                           
                                  ),

                                  //? ILCE LİSTESİ
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: DropdownSearch<IlceList>(
                                      enabled: !isButtonBeklemedeMi,
                                      popupProps: PopupProps.bottomSheet(
                                        bottomSheetProps: BottomSheetProps(
                                          backgroundColor:
                                              Color.fromARGB(255, 70, 135, 209),
                                        ),
                                        itemBuilder: (
                                          BuildContext context,
                                          IlceList item,
                                          bool isSelected,
                                        ) {
                                          return Container(
                                            // color: Color.fromARGB(255, 184, 125, 22),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: !isSelected
                                                ? null
                                                : BoxDecoration(
                                                    border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Color.fromARGB(
                                                        255,
                                                        202,
                                                        202,
                                                        198), //yazının arka rengi
                                                  ),
                                            child: ListTile(
                                              //tileColor: Color.fromARGB(255, 52, 138, 230),
                                              selected: isSelected,
                                              title: Center(
                                                  child: Text(
                                                item.name ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              )),
                                            ),
                                          );
                                        },
                                        showSelectedItems: true,
                                        emptyBuilder: (BuildContext context,
                                            searchEntry) {
                                          return Container(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Listede Veri Bulunamadı.",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (() =>
                                                        Navigator.of(context)
                                                            .pop()),
                                                    child: Text("Kapat"),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        // disabledItemFn: (String s) =>
                                        //     s.startsWith('I'),
                                      ),
                                      itemAsString: (item) => item.name!,
                                      items: ilceList,
                                      compareFn: (i, s) =>
                                          i.isEqual(s) ?? false,
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        textAlign: TextAlign.center,
                                        baseStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          floatingLabelAlignment:
                                              FloatingLabelAlignment.start,

                                          floatingLabelStyle: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),

                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.pink,
                                            ),
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Color.fromARGB(
                                                  255, 190, 195, 193),
                                            ),
                                          ),

                                          //   suffixIcon: Icon(Icons.abc),
                                          //    icon: Icon(Icons.extension),
                                          //   disabledBorder: InputBorder.none,
                                          labelText: "İlçe",
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Color.fromARGB(
                                                  255, 32, 30, 30)),
                                        ),
                                      ),
                                      onChanged: ((deger) {
                                        _selectedMuhtarlik = null;
                                        _muhtarlikDropDownProgKey.currentState!
                                            .clear();
                                        servisler
                                            .getMuhtarlikList(
                                                "${deger!.value}", "1")
                                            .then((value) async {
                                          if (value != null) {
                                            if (muhtarlikList != null) {
                                              muhtarlikList.clear();
                                            } else {
                                              muhtarlikList = [];
                                            }

                                            setState(() {
                                              muhtarlikList.addAll(value);
                                            });
                                            isIlceChanged = true;
                                          }
                                        });

                                        debugPrint(deger.name);
                                        debugPrint(deger.value);
                                        _ilceDegisim = deger.value;
                                        muhtarlikKayitId = null;
                                        ilceKayit = deger.value.toString();
                                      }),
                                      selectedItem: gelenIlce.isNotEmpty
                                          ? ilceList.elementAt(gelenIlce[0].id!)
                                          : null,
                                    ),
                                  ),
                                  //? MUHTARLIK
                                  Visibility(
                                    visible:
                                        isMuhtarlikVisibility ? true : false,
                                    child: Card(
                                      color: sabitler.kMainColor,
                                      shadowColor:
                                          Color.fromARGB(255, 212, 77, 122),
                                      // color: Colors.white,
                                      elevation: 10.0,
                                      shape: new RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.amber),
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, bottom: 8),
                                        child: Column(
                                          children: [
                                            // MUHTARLIK LİSTESİ

                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 1),
                                              child:
                                                  DropdownSearch<MuhtarlikList>(
                                                key: _muhtarlikDropDownProgKey,
                                                enabled: isIlceChanged,

                                                // selectedItem: null,
                                                popupProps:
                                                    PopupProps.bottomSheet(
                                                  showSearchBox: true,
                                                  bottomSheetProps:
                                                      BottomSheetProps(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 70, 135, 209),
                                                  ),
                                                  itemBuilder: (
                                                    BuildContext context,
                                                    MuhtarlikList item,
                                                    bool isSelected,
                                                  ) {
                                                    return Container(
                                                      // color: Color.fromARGB(255, 184, 125, 22),
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8),
                                                      decoration: !isSelected
                                                          ? null
                                                          : BoxDecoration(
                                                              border: Border.all(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: Color.fromARGB(
                                                                  255,
                                                                  202,
                                                                  202,
                                                                  198), //yazının arka rengi
                                                            ),
                                                      child: ListTile(
                                                        //tileColor: Color.fromARGB(255, 52, 138, 230),
                                                        selected: isSelected,
                                                        title: Center(
                                                            child: Text(
                                                          item.unvani ?? '',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isSelected
                                                                ? Colors.black
                                                                : Colors.white,
                                                          ),
                                                        )),
                                                      ),
                                                    );
                                                  },
                                                  showSelectedItems: true,
                                                  emptyBuilder:
                                                      (BuildContext context,
                                                          searchEntry) {
                                                    return Container(
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "Herhangi bir seçim yapmadınız.",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: (() =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop()),
                                                              child:
                                                                  Text("Kapat"),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                itemAsString: (item) =>
                                                    item.unvani!,
                                                items: muhtarlikList,
                                                compareFn: (i, s) =>
                                                    i.isEqual(s) ?? false,
                                                dropdownDecoratorProps:
                                                    DropDownDecoratorProps(
                                                  textAlign: TextAlign.end,
                                                  baseStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  dropdownSearchDecoration:
                                                      InputDecoration(
                                                    floatingLabelAlignment:
                                                        FloatingLabelAlignment
                                                            .start,

                                                    floatingLabelStyle:
                                                        TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),

                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 15),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(13),
                                                      ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: Colors.pink,
                                                      ),
                                                    ),

                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(13),
                                                      ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: Color.fromARGB(
                                                            255, 190, 195, 193),
                                                      ),
                                                    ),

                                                    //   suffixIcon: Icon(Icons.abc),
                                                    //    icon: Icon(Icons.extension),
                                                    //   disabledBorder: InputBorder.none,
                                                    labelText: "Muhtarlık",
                                                    labelStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            255, 32, 30, 30)),
                                                  ),
                                                ),
                                                onChanged: ((value) {
                                                  if (value != null) {
                                                    debugPrint(value.unvani);
                                                    setState(() {
                                                      muhatapSecimController
                                                          .text = "";
                                                      muhtarlikKayitId = value
                                                          .sbsMuhatapId
                                                          .toString();
                                                    });
                                                  }
                                                }),
                                                selectedItem: !isIlceChanged
                                                    ? _selectedMuhtarlik
                                                    : null,
                                              ),
                                            ),

                                            //? YAPI ADI SEÇİM

                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4, 10, 4, 0),
                                              child: TextField(
                                                enabled: isYapiDetayTrue,
                                                readOnly: true,
                                                textAlign: TextAlign.center,
                                                controller: _yapiAdiController,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 15),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(13),
                                                    ),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Color.fromARGB(
                                                          255, 190, 195, 193),
                                                    ),
                                                  ),

                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(13),
                                                    ),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Color.fromARGB(
                                                          255, 190, 195, 193),
                                                    ),
                                                  ),
                                                  //    suffixText: "vhjvjvhv",

                                                  suffixIcon: IconButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              DetailScreenTalepGoster(
                                                                  kbsAdresData:
                                                                      kbsAdresData!),
                                                        ),
                                                      );

                                                      // if (ilceUavt != null) {
                                                      //   //   _yapiAdiController.text
                                                      //   gelenYapiBilgisi = (await Navigator.of(context)
                                                      //       .push(MaterialPageRoute(
                                                      //           builder: (context) => DetailScreenTalep(
                                                      //                 muhtarlikId: _ilce!,
                                                      //                 ilceUavtId: ilceUavt ?? "",
                                                      //               )))) as YapiAdlari?;
                                                      //   if (gelenYapiBilgisi != null) {
                                                      //     _yapiAdiController.text =
                                                      //         gelenYapiBilgisi!.source.categoryData.ad;
                                                      //   }

                                                      // }
                                                    },
                                                    icon: Icon(Icons
                                                        .account_circle_sharp),
                                                  ),

                                                  //   disabledBorder: InputBorder.none,
                                                  labelText: "Yapı Adı Detay",
                                                  labelStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Color.fromARGB(
                                                          255, 32, 30, 30)),
                                                ),
                                              ),
                                            ),

                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      1, 10, 3, 5),
                                              child: TextField(
                                                enabled: isYapiDetayTrue,
                                                readOnly: true,
                                                textAlign: TextAlign.center,
                                                controller:
                                                    _muhtarBilgisiController,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 15),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(13),
                                                    ),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Color.fromARGB(
                                                          255, 190, 195, 193),
                                                    ),
                                                  ),

                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(13),
                                                    ),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Color.fromARGB(
                                                          255, 190, 195, 193),
                                                    ),
                                                  ),
                                                  //    suffixText: "vhjvjvhv",

                                                  suffixIcon: IconButton(
                                                    onPressed: () async {
                                                      print(_muhtarBilgisi!
                                                          .telefon1);
                                                      refurbishedTel = "0" +
                                                          _muhtarBilgisi!
                                                              .telefon1;

                                                      debugPrint(
                                                          refurbishedTel);

                                                      if (await canLaunchUrl(
                                                        Uri(
                                                          scheme: 'tel',
                                                          path: refurbishedTel,
                                                        ),
                                                      )) {
                                                        await launchUrl(
                                                          Uri(
                                                            scheme: 'tel',
                                                            path:
                                                                refurbishedTel,
                                                          ),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    'Numara çevrilemedi. $refurbishedTel')));
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.phone,
                                                      color: Color.fromARGB(
                                                          255, 61, 232, 109),
                                                    ),
                                                  ),

                                                  //   disabledBorder: InputBorder.none,
                                                  labelText: "Muhtar Bilgisi",
                                                  labelStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Color.fromARGB(
                                                          255, 32, 30, 30)),
                                                ),
                                              ),

                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment
                                              //           .spaceBetween,
                                              //   children: [
                                              //     CircleAvatar(
                                              //         child: Text("asdf "),
                                              //         minRadius: 30,
                                              //         maxRadius: 45,
                                              //         backgroundColor:
                                              //             Colors.amber),
                                              //     Text("Muhtar Adı"),
                                              //     IconButton(
                                              //       onPressed: () {},
                                              //       icon: Icon(
                                              //         Icons
                                              //             .phone_forwarded_rounded,
                                              //         color: Colors.green,
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  //? MUHATAP SEÇİMİ

                                  Visibility(
                                    visible:
                                        isMuhtarlikVisibility ? false : true,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: TextField(
                                        // onTap: () async {
                                        //   print(context);

                                        //   secilenMuhatap =
                                        //       await Navigator.maybeOf(context).push(
                                        //           MaterialPageRoute(
                                        //               builder:
                                        //                   (BuildContext context) =>
                                        //                       MuhatapSecim()));

                                        //   setState(() {
                                        //     // gelenMuhatapUnvan(secilenMuhatap);
                                        //     // _muhatapSecim.text = voidMuhatap;
                                        //     // _muhtarlik = null;
                                        //     // gelenMuhtarlikId = null;
                                        //     // print(_muhtarlik);
                                        //     // _muhatap = secilenMuhatap;
                                        //     // print(_muhatap);
                                        //   });
                                        // },

                                        textAlign: TextAlign.center,
                                        //   enabled: true,
                                        //  autofocus: autoFocustxt,
                                        //maxLength: 50,
                                        //readOnly: readOnlyTxt,
                                        //       onChanged: (_) {},
                                        //  inputFormatters: klavyeFormat,
                                        // keyboardType: klavyetipi,
                                        //   maxLines: n,
                                        // minLines: minLinesTxt,

                                        controller: muhatapSecimController,

                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),

                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Color.fromARGB(
                                                  255, 190, 195, 193),
                                            ),
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Color.fromARGB(
                                                  255, 190, 195, 193),
                                            ),
                                          ),
                                          //    suffixText: "vhjvjvhv",

                                          // suffixIcon: IconButton(
                                          //   onPressed: () async {
                                          //     // onTap: () async {

                                          //     secilenMuhatap =
                                          //         await Navigator.of(context)
                                          //             .push(MaterialPageRoute(
                                          //                 builder: (context) =>
                                          //                     MuhatapSecim()));
                                          //     if (secilenMuhatap != null) {
                                          //       setState(() {
                                          //         // gelenMuhatapUnvan(secilenMuhatap);
                                          //         // _muhatapSecim.text = voidMuhatap;
                                          //         // _muhtarlik = null;
                                          //         // gelenMuhtarlikId = null;
                                          //         // print(_muhtarlik);
                                          //         // _muhatap = secilenMuhatap;
                                          //         // print(_muhatap);
                                          //         muhatapSecimController.text =
                                          //             secilenMuhatap!.unvani!;
                                          //         _muhtarlikDropDownProgKey
                                          //             .currentState!
                                          //             .clear();
                                          //       });
                                          //     }
                                          //   },
                                          //   icon:
                                          //       Icon(Icons.account_circle_sharp),
                                          // ),

                                          //   disabledBorder: InputBorder.none,
                                          labelText: "Muhatap Seçim",
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Color.fromARGB(
                                                  255, 32, 30, 30)),
                                        ),
                                      ),
                                    ),
                                  ),

                                  //? ÇÖZÜM TÜRÜ LİSTESİ
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: DropdownSearch<CozumTuruList>(
                                      enabled: !isButtonBeklemedeMi,
                                      key: _cozumTuruDropDownProgKey,
                                      // enabled: isIlceChanged,

                                      // selectedItem: null,
                                      popupProps: PopupProps.bottomSheet(
                                        bottomSheetProps: BottomSheetProps(
                                          backgroundColor:
                                              Color.fromARGB(255, 70, 135, 209),
                                        ),
                                        itemBuilder: (
                                          BuildContext context,
                                          CozumTuruList item,
                                          bool isSelected,
                                        ) {
                                          return Container(
                                            // color: Color.fromARGB(255, 184, 125, 22),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: !isSelected
                                                ? null
                                                : BoxDecoration(
                                                    border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Color.fromARGB(
                                                        255,
                                                        202,
                                                        202,
                                                        198), //yazının arka rengi
                                                  ),
                                            child: ListTile(
                                              //tileColor: Color.fromARGB(255, 52, 138, 230),
                                              selected: isSelected,
                                              title: Center(
                                                  child: Text(
                                                item.adi ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              )),
                                            ),
                                          );
                                        },
                                        showSelectedItems: true,
                                        emptyBuilder: (BuildContext context,
                                            searchEntry) {
                                          return Container(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Herhangi bir seçim yapmadınız.",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (() =>
                                                        Navigator.of(context)
                                                            .pop()),
                                                    child: Text("Kapat"),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      itemAsString: (item) => item.adi!,
                                      items: cozumTuruList,
                                      compareFn: (i, s) =>
                                          i.isEqual(s) ?? false,
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        textAlign: TextAlign.center,
                                        baseStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          floatingLabelAlignment:
                                              FloatingLabelAlignment.start,

                                          floatingLabelStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),

                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.pink,
                                            ),
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Color.fromARGB(
                                                  255, 190, 195, 193),
                                            ),
                                          ),

                                          //   suffixIcon: Icon(Icons.abc),
                                          //    icon: Icon(Icons.extension),
                                          //   disabledBorder: InputBorder.none,
                                          labelText: "Çözüm Türü",
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Color.fromARGB(
                                                  255, 18, 17, 17)),
                                        ),
                                      ),
                                      onChanged: ((value) {
                                        _selectedArizaNedeni = null;
                                        if (value != null) {
                                          if (_arizaNedeniDropDownProgKey
                                                  .currentState !=
                                              null) {
                                            _arizaNedeniDropDownProgKey
                                                .currentState!
                                                .clear();
                                          }

                                          setState(() {
                                            arizaNedeniList.clear();
                                            servisler
                                                .getArizaNedeniList(
                                                    value.id.toString())
                                                .then((value) async {
                                              arizaNedeniList.addAll(value);
                                            });
                                          });

                                          debugPrint(value.adi);
                                          debugPrint(value.id.toString());
                                          cozumTuruIdKayit =
                                              value.id.toString();
                                        }
                                      }),
                                      selectedItem: _selectedCozumTuru,
                                    ),
                                  ),
                                  //? ARIZA NEDENİ LİSTESİ
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: DropdownSearch<ArizaNedeniList>(
                                      enabled: !isButtonBeklemedeMi,
                                      key: _arizaNedeniDropDownProgKey,
                                      // enabled: isIlceChanged,

                                      // selectedItem: null,
                                      popupProps: PopupProps.bottomSheet(
                                        bottomSheetProps: BottomSheetProps(
                                          backgroundColor:
                                              Color.fromARGB(255, 70, 135, 209),
                                        ),
                                        itemBuilder: (
                                          BuildContext context,
                                          ArizaNedeniList item,
                                          bool isSelected,
                                        ) {
                                          return Container(
                                            // color: Color.fromARGB(255, 184, 125, 22),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: !isSelected
                                                ? null
                                                : BoxDecoration(
                                                    border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Color.fromARGB(
                                                        255,
                                                        202,
                                                        202,
                                                        198), //yazının arka rengi
                                                  ),
                                            child: ListTile(
                                              //tileColor: Color.fromARGB(255, 52, 138, 230),
                                              selected: isSelected,
                                              title: Center(
                                                  child: Text(
                                                item.adi ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              )),
                                            ),
                                          );
                                        },
                                        showSelectedItems: true,
                                        emptyBuilder: (BuildContext context,
                                            searchEntry) {
                                          return Container(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Çözüm Türü Seçmelisiniz...",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (() =>
                                                        Navigator.of(context)
                                                            .pop()),
                                                    child: Text("Kapat"),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      itemAsString: (item) => item.adi!,
                                      items: arizaNedeniList,
                                      compareFn: (i, s) =>
                                          i.isEqual(s) ?? false,
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        textAlign: TextAlign.center,
                                        baseStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          floatingLabelAlignment:
                                              FloatingLabelAlignment.start,

                                          floatingLabelStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),

                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.pink,
                                            ),
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(13),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Color.fromARGB(
                                                  255, 190, 195, 193),
                                            ),
                                          ),

                                          //   suffixIcon: Icon(Icons.abc),
                                          //    icon: Icon(Icons.extension),
                                          //   disabledBorder: InputBorder.none,
                                          labelText: "Arıza Nedeni",
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Color.fromARGB(
                                                  255, 32, 30, 30)),
                                        ),
                                      ),
                                      onChanged: ((value) {
                                        if (value != null) {
                                          setState(() {});
                                          debugPrint(value.adi);
                                          debugPrint(value.id.toString());
                                          arizaNedeniIdKayit =
                                              value.id.toString();
                                        }
                                      }),
                                      selectedItem: _selectedArizaNedeni,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //? SONUÇ
                          Card(
                            color: sabitler.kMainColor,
                            shadowColor: Color.fromARGB(255, 212, 77, 122),
                            // color: Colors.white,
                            elevation: 50.0,
                            shape: new RoundedRectangleBorder(
                              side: BorderSide(color: Colors.amber),
                              borderRadius: new BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                children: [
                                  DropdownSearch<SonucTuruList>(
                                    enabled: !isButtonBeklemedeMi,
                                    key: _sonucTuruDropDownProgKey,
                                    // enabled: isIlceChanged,

                                    // selectedItem: null,
                                    popupProps: PopupProps.bottomSheet(
                                      bottomSheetProps: BottomSheetProps(
                                        backgroundColor:
                                            Color.fromARGB(255, 70, 135, 209),
                                      ),
                                      itemBuilder: (
                                        BuildContext context,
                                        SonucTuruList item,
                                        bool isSelected,
                                      ) {
                                        return Container(
                                          // color: Color.fromARGB(255, 184, 125, 22),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: !isSelected
                                              ? null
                                              : BoxDecoration(
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Color.fromARGB(
                                                      255,
                                                      202,
                                                      202,
                                                      198), //yazının arka rengi
                                                ),
                                          child: ListTile(
                                            //tileColor: Color.fromARGB(255, 52, 138, 230),
                                            selected: isSelected,
                                            title: Center(
                                                child: Text(
                                              item.adi ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            )),
                                          ),
                                        );
                                      },
                                      showSelectedItems: true,
                                      emptyBuilder:
                                          (BuildContext context, searchEntry) {
                                        return Container(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Herhangi bir seçim yapmadınız.",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: (() =>
                                                      Navigator.of(context)
                                                          .pop()),
                                                  child: Text("Kapat"),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    itemAsString: (item) => item.adi!,
                                    items: sonucTuruList,
                                    compareFn: (i, s) => i.isEqual(s) ?? false,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      textAlign: TextAlign.center,
                                      baseStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      dropdownSearchDecoration: InputDecoration(
                                        floatingLabelAlignment:
                                            FloatingLabelAlignment.start,

                                        floatingLabelStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),

                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(13),
                                          ),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.pink,
                                          ),
                                        ),

                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(13),
                                          ),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Color.fromARGB(
                                                255, 190, 195, 193),
                                          ),
                                        ),

                                        //   suffixIcon: Icon(Icons.abc),
                                        //                               //    icon: Icon(Icons.extension),
                                        //                               //   disabledBorder: InputBorder.none,
                                        labelText: "Sonuç Türü",
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Color.fromARGB(
                                                255, 32, 30, 30)),
                                      ),
                                    ),
                                    onChanged: ((value) {
                                      if (value != null) {
                                        _selectedSonucTuru = value;
                                        debugPrint(value.adi);
                                        debugPrint(value.id.toString());
                                        sonucIdKayit = value.id.toString();
                                      }
                                    }),
                                    selectedItem: _selectedSonucTuru,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: MyDetayTextField3(
                                      autoFocustxt: true,
                                      maxLinesTxt: null,
                                      readOnlyTxt: false,
                                      labelTxt: "Sonuç Açıklama",
                                      controllerTxt: sonucAciklamaController,
                                      onChangedTxt: (value) {
                                        isSonucAciklamaChanged = true;
                                        sonucAciklamaKayit = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //? RESIM GÖSTERİİMİ
                          Card(
                            color: sabitler.kMainColor,
                            shadowColor: Color.fromARGB(255, 212, 77, 122),
                            // color: Colors.white,
                            elevation: 50.0,
                            shape: new RoundedRectangleBorder(
                              side: BorderSide(color: Colors.amber),
                              borderRadius: new BorderRadius.circular(20.0),
                            ),
                            child:
                                //  Image.network( "https://mobilservices.kocaeli.bel.tr/WebForms/ShowImage.ashx?id=4343830")

                                ShowImage(
                              resimListesi: resimListesi,
                              buttonCarouselController:
                                  buttonCarouselController,
                              urlList: urlList,
                            ),
                          ),
                          // ElevatedButton(
                          //   onPressed: () async {
                          //     await pushData();
                          //   },
                          //   child: Text(
                          //     "KAYDET",
                          //     style: TextStyle(fontSize: 22, color: Colors.amber),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : CircularProgressIndicator());
  }

  Future<void> islemeAlButton(
    TextEditingController _aciklama,
    BuildContext context,

    // TextEditingController _telefon,
    // TextEditingController _bildirim_tarihi
  ) async {
    if (_aciklama.text.length < 6) {
      kayitbos(
          () {},
          "TAMAM",
          DialogType.error,
          "Açıklama alanı en az 6 karakter olmalıdır.",
          Colors.red,
          "Hata",
          null,
          context);
    } else {
      // bool isCompleted = false;
      // await pushData().then((value) {});
      // isCompleted == false
      //     ? showDialog(
      //         barrierDismissible: false,
      //         context: context,
      //         barrierColor: Colors.transparent,
      //         builder: (BuildContext ctx) {
      //           return AlertDialog(
      //             actionsAlignment: MainAxisAlignment.center,
      //             elevation: 10,
      //             title: const Text('Lütfen Bekleyiniz...'),
      //             content: SizedBox(
      //               height: 50,
      //               width: 50,
      //               child: Center(
      //                 child: CircularProgressIndicator(),
      //               ),
      //             ),
      //             actions: [
      //               TextButton(
      //                 onPressed: () {
      //                   Navigator.pop(ctx);
      //                 },
      //                 child: const Text('Kapat'),
      //               )
      //             ],
      //           );
      //         })
      //     : Navigator.pop(context);

      setState(
        () {
          //  isLoadingKaydet = true;

          //  exBildirim = _bildirim_tarihi.text;
          //   debugPrint("aciklama : " + aciklama);
          //  pbsPersonelIslemeAlan = widget.userName;
          //          debugPrint("filename :" + fileName);
          //   debugPrint("dosyacik :" + dosyacik);
          // debugPrint("base64file :" + base64File.toString());

          durumuKayit = "ISLEME_ALINDI";
          //   gelenDurumu = "İşleme Alındı";
          onayKayit = "HAYIR";
        },
      );

      await showDialog(
        context: context,
        builder: (context) => FutureProgressDialog(
            pushData(buttonTypes.islemeAl),
            message: Text('Lütfen Bekleyiniz...')),
      );

      kayitbos(
        () {
          setState(() {
            // isKayitBasariliMi = true;

            selectedDurumu = durumList[1];
            isIslemeAlindimi = true;

            // super.widget;
            //ref.refresh(arizaListesiProvider(widget.userName!).future);
          });
        },
        "TAMAM",
        DialogType.success,
        "Kayıt işlemi gerçekleştirilmiştir.",
        Colors.lightGreen,
        "Onay",
        null,
        context,
      );
    }
  }

  Future<void> baskaServiseAtaButton(BuildContext context,
      bool _muhtarlikVisible, bool arizayiCogaltVisibiltyAta) async {
    TextEditingController _personelSecimController = TextEditingController();
    String? _ustTuru, _arizaTuru;
    dynamic selectedRadioValue = 0;
    bool isSelectedRadio = true;
    String? pageResultDuzenleyen;
    setState(() {
      gelenUstTur = _ustTuru;
      //   arizaTuruGetir(gelenUstTur);

      showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              this._setStateModel = setModalState;
              return Scaffold(
                backgroundColor: Color.fromARGB(255, 70, 135, 209),
                body: AlertDialog(
                  backgroundColor: Color.fromARGB(255, 70, 135, 209),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  contentPadding: const EdgeInsets.all(16.0),
                  content: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile(
                          activeColor: Colors.amber,
                          title: Text(
                            "SERVİSE ATA",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          value: 0,
                          groupValue: selectedRadioValue,
                          onChanged: ((value) {
                            _setStateModel!(() {
                              _ustTuruSelection = null;
                              _arizaTuruListe = null;

                              selectedRadioValue = value;
                              debugPrint(selectedRadioValue.toString());
                              isSelectedRadio = true;
                            });
                          }),
                        ),

                        Visibility(
                          visible: isSelectedRadio == true ? true : false,
                          child: Container(
                            child: Column(
                              children: [
//? ARIZA ÜST TÜRÜ

                                DropdownSearch<UstTuruList>(
                                  popupProps: PopupProps.bottomSheet(
                                    bottomSheetProps: BottomSheetProps(
                                      backgroundColor:
                                          Color.fromARGB(255, 70, 135, 209),
                                    ),
                                    itemBuilder: (
                                      BuildContext context,
                                      UstTuruList item,
                                      bool isSelected,
                                    ) {
                                      return Container(
                                        // color: Color.fromARGB(255, 184, 125, 22),
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        decoration: !isSelected
                                            ? null
                                            : BoxDecoration(
                                                border: Border.all(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Color.fromARGB(
                                                    255,
                                                    202,
                                                    202,
                                                    198), //yazının arka rengi
                                              ),
                                        child: ListTile(
                                          //tileColor: Color.fromARGB(255, 52, 138, 230),
                                          selected: isSelected,
                                          title: Center(
                                              child: Text(
                                            item.name ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          )),
                                        ),
                                      );
                                    },
                                    showSelectedItems: true,
                                    emptyBuilder:
                                        (BuildContext context, searchEntry) {
                                      return Container(
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Listede Veri Bulunamadı.",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: (() =>
                                                    Navigator.of(context)
                                                        .pop()),
                                                child: Text("Kapat"),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    // disabledItemFn: (String s) =>
                                    //     s.startsWith('I'),
                                  ),
                                  itemAsString: (item) => item.name!,
                                  items: ustTuruList,
                                  compareFn: (i, s) => i.isEqual(s) ?? false,
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    textAlign: TextAlign.center,
                                    baseStyle: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    dropdownSearchDecoration: InputDecoration(
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,

                                      floatingLabelStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),

                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(13),
                                        ),
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: Colors.pink,
                                        ),
                                      ),

                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(13),
                                        ),
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: Colors.amber,
                                        ),
                                      ),

                                      //   suffixIcon: Icon(Icons.abc),
                                      //    icon: Icon(Icons.extension),
                                      //   disabledBorder: InputBorder.none,
                                      labelText: "Arıza Üst Türü",
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 32, 30, 30)),
                                    ),
                                  ),
                                  onChanged: ((deger) {
                                    setState(() {
                                      _ustTuruSelection = deger;
                                      if (deger != null) {
                                        if (_arizaTuruDropDownProgKey
                                                .currentState !=
                                            null) {
                                          _arizaTuruDropDownProgKey
                                              .currentState!
                                              .clear();
                                        }

                                        _setStateModel!(() {
                                          arizaTurList.clear();

                                          arizaTuruGetir(
                                              _ustTuruSelection!.value!);
                                        });
                                        gidenUstTur = _ustTuruSelection!.value;
                                      }

                                      //    arizaTuruGetir(_ustTuruSelection.name.toString());
                                    });
                                  }),
                                  selectedItem: _ustTuruSelection,
                                ),

//? ARIZA TÜRÜ

                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: DropdownSearch<ArizaTuruList>(
                                    key: _arizaTuruDropDownProgKey,
                                    popupProps: PopupProps.bottomSheet(
                                      bottomSheetProps: BottomSheetProps(
                                        backgroundColor:
                                            Color.fromARGB(255, 70, 135, 209),
                                      ),
                                      itemBuilder: (
                                        BuildContext context,
                                        ArizaTuruList item,
                                        bool isSelected,
                                      ) {
                                        return Container(
                                          // color: Color.fromARGB(255, 184, 125, 22),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: !isSelected
                                              ? null
                                              : BoxDecoration(
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Color.fromARGB(
                                                      255,
                                                      202,
                                                      202,
                                                      198), //yazının arka rengi
                                                ),
                                          child: ListTile(
                                            //tileColor: Color.fromARGB(255, 52, 138, 230),
                                            selected: isSelected,
                                            title: Center(
                                                child: Text(
                                              item.adi ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            )),
                                          ),
                                        );
                                      },
                                      showSelectedItems: true,
                                      emptyBuilder:
                                          (BuildContext context, searchEntry) {
                                        return Container(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Listede Veri Bulunamadı.",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: (() =>
                                                      Navigator.of(context)
                                                          .pop()),
                                                  child: Text("Kapat"),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      // disabledItemFn: (String s) =>
                                      //     s.startsWith('I'),
                                    ),
                                    itemAsString: (item) => item.adi!,
                                    items: arizaTurList,
                                    compareFn: (i, s) => i.isEqual(s) ?? false,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      textAlign: TextAlign.center,
                                      baseStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      dropdownSearchDecoration: InputDecoration(
                                        floatingLabelAlignment:
                                            FloatingLabelAlignment.start,

                                        floatingLabelStyle: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),

                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(13),
                                          ),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.pink,
                                          ),
                                        ),

                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(13),
                                          ),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.amber,
                                            //      Color.fromARGB(
                                            //        255, 190, 195, 193),
                                          ),
                                        ),

                                        //   suffixIcon: Icon(Icons.abc),
                                        //    icon: Icon(Icons.extension),
                                        //   disabledBorder: InputBorder.none,
                                        labelText: "Arıza Türü",
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Color.fromARGB(
                                                255, 32, 30, 30)),
                                      ),
                                    ),
                                    onChanged: ((deger) {
                                      setState(() {
                                        _arizaTuruListe = deger;

                                        gidenArizaTuru = deger == null
                                            ? null
                                            : deger.id.toString();
                                        debugPrint(
                                            "$gidenUstTur  $gidenArizaTuru");
                                      });
                                    }),
                                    selectedItem: _arizaTuruListe,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ***** PERSONEL SEÇİM ********

                        Visibility(
                          visible: !arizayiCogaltVisibiltyAta,
                          child: Visibility(
                            visible: _muhtarlikVisible,
                            child: //Container height 200 kaldırıldı
                                Container(
                              // color: Color.fromARGB(255, 214, 143, 166),
                              height: 130,
                              child: Column(
                                children: [
                                  RadioListTile(
                                    activeColor: Colors.amber,
                                    title: Text(
                                      "PERSONELE ATA",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    value: 1,
                                    groupValue: selectedRadioValue,
                                    onChanged: ((value) {
                                      _setStateModel!(() {
                                        selectedRadioValue = value;
                                        debugPrint(
                                            selectedRadioValue.toString());
                                        isSelectedRadio = false;

                                        _personelSecimController.text = "";
                                        pageResultDuzenleyen = null;
                                      });
                                    }),
                                  ),
                                  Visibility(
                                    visible:
                                        isSelectedRadio == false ? true : false,
                                    child: Expanded(
                                      //TODO: PERSONEL VERİSİ sadece A-TAKIMI olacak şekilde değiştirilecek
                                      child: MyDetayTextField3(
                                        readOnlyTxt: true,
                                        labelTxt: "Atanacak Personel",
                                        controllerTxt: _personelSecimController,
                                        suffixIcon: !isPersonelLoaded
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 181, 204, 62),
                                                  color: Color.fromARGB(
                                                      255, 201, 92, 101),
                                                ),
                                              )
                                            : IconButton(
                                                onPressed: () async {
                                                  pageResultDuzenleyen =
                                                      await Navigator.of(
                                                              context)
                                                          .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PersonelSecim(
                                                        idKbsOrgut: widget
                                                            .yetkiler
                                                            .idKbsOrgut!,
                                                        gelenListe: getPersonel,
                                                        userId: widget
                                                            .yetkiler.idPbsKisi,
                                                        idKbsServis: widget
                                                            .yetkiler
                                                            .idKbsServis!,
                                                        idUstKbsServis: widget
                                                            .yetkiler
                                                            .idUstKbsServis!,
                                                      ),
                                                    ),
                                                  );

                                                  debugPrint(
                                                      "kullanıcı değiştir butonuna basıldı");

                                                  debugPrint(
                                                      pageResultDuzenleyen
                                                          .toString());

                                                  setState(() {
                                                    var item2 = getPersonel[0]
                                                        .result
                                                        .where((element) =>
                                                            element.pbskisi
                                                                .toString() ==
                                                            pageResultDuzenleyen)
                                                        .toList();
                                                    if (item2.length > 0) {
                                                      debugPrint("ceee");
                                                      debugPrint(
                                                          item2.toString());

                                                      debugPrint(
                                                          item2[0].adsoyad);

                                                      _personelSecimController
                                                              .text =
                                                          item2[0].adsoyad!;
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.account_circle_sharp,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        //  SizedBox(height: 10.0),
                        //********BUTONLAR********* */

                        InkWell(
                          child: Container(
                            padding: EdgeInsets.only(top: 5.0, bottom: 1.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(255, 255, 253, 253)),
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                    child: const Text('Çıkış',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),

                                TextButton(
                                  child: const Text('Gönder',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    setState(() {
                                      //   isLoadingKaydet = true;
                                      // telefon =
                                      //     _telefon
                                      //         .text;
                                      // aciklama =
                                      //     _aciklama
                                      //         .text;
                                      // sonucAciklama =
                                      //     _sonucAciklama
                                      //         .text;
                                      // exBildirim =
                                      //     _bildirim_tarihi
                                      //         .text;
                                      // debugPrint("aciklama : " +
                                      //     aciklama);
                                      //          debugPrint("filename :" + fileName);
                                      //   debugPrint("dosyacik :" + dosyacik);
                                      // debugPrint("base64file :" + base64File.toString());

//! arıza üst türünü ve arıza türünü ekle.

                                      durumuKayit = "BEKLEMEDE";
                                    });

                                    projectFiltered!.idPbsPersonelIslemYapan ==
                                            null
                                        ? idPbsPersonelIslemYapanKayit =
                                            pageResultDuzenleyen
                                        : projectFiltered!
                                                    .idPbsPersonelIslemYapanIki ==
                                                null
                                            ? idPbsPersonelIslemYapanIkiKayit =
                                                pageResultDuzenleyen
                                            : projectFiltered!
                                                        .idPbsPersonelIslemYapanUc ==
                                                    null
                                                ? idPbsPersonelIslemYapanUcKayit =
                                                    pageResultDuzenleyen
                                                : idPbsPersonelIslemYapanDortKayit =
                                                    pageResultDuzenleyen;
                                    cozumTuruIdKayit = null;
                                    arizaNedeniIdKayit = null;
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                              pushData(
                                                  buttonTypes.baskaServiseAta),
                                              message:
                                                  Text('Lütfen Bekleyiniz...')),
                                    );

                                    kayitbos(
                                      () {
                                        setState(() {
                                          // isKayitBasariliMi = true;
                                          // super.widget;
                                          // ref.refresh(arizaListesiProvider(
                                          //         widget.userName!)
                                          //     .future);
                                          Navigator.pop(context);
                                          // Navigator.pushReplacement(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           //    anaSayfa( locationText: username, sifText: pass,),
                                          //           TabsRiverpod(
                                          //         token: widget.token,
                                          //         locationText: widget.userName,
                                          //         yetkiler: widget.yetkiler,
                                          //       ),
                                          //     ));
                                        });
                                      },
                                      "TAMAM",
                                      DialogType.success,
                                      "Atama İşlemi gerçekleştirilmiştir.",
                                      Colors.lightGreen,
                                      "Onay",
                                      null,
                                      context,
                                    );
                                  },
                                ),

                                //*** */
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          });
    });
  }

  void servisFormuButton(
      String _durumu, BuildContext context, String _ilceDegisim) {
    _durumu == "Beklemede"
        ? kayitbos(() {}, "TAMAM", DialogType.error, "Önce İşleme Almalısınız",
            Colors.red, "Hata", null, context)
        : projectFiltered!.sonucAciklama == ""
            ? kayitbos(() {}, "TAMAM", DialogType.error,
                "Sonuç Açıklama Boş Olamaz!", Colors.red, "Hata", null, context)
            : projectFiltered!.sonucAciklama == null &&
                    sonucAciklamaKayit == null
                ? kayitbos(
                    () {},
                    "TAMAM",
                    DialogType.error,
                    "Sonuç Açıklama Boş Olamaz!",
                    Colors.red,
                    "Hata",
                    null,
                    context)
                : gelenIlce.isEmpty && _ilceDegisim == "null"
                    ? kayitbos(() {}, "TAMAM", DialogType.error,
                        "İlçe Boş Olamaz!", Colors.red, "Hata", null, context)
                    : (getPersonel.isNotEmpty == true)
                        ? Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ServisFormu(
                                idPbsKisi: widget.yetkiler.idPbsKisi,
                                //   durumuTamamlandi: finished,
                                idBatAriza:
                                    int.parse(projectFiltered!.id.toString()),
                                ustTuru: gelenUstTur,
                                formTuru: "SERVIS",
                                idSisKullaniciGuncelleyen:
                                    widget.yetkiler.idKullanici,
                                idSisKullaniciKaydeden:
                                    widget.yetkiler.idKullanici,
                                ipAdresi: widget.ipAdresi,
                                gelenilce: bolgeAdi,
                                gelenListe: getPersonel,
                                idKbsOrgut: widget.yetkiler.idKbsOrgut!,
                              ),
                              //  ServisFormu(
                              //     idBatAriza: idSave,
                              //     ustTuru: gelenUstTuru),
                            ),
                          )
                        : kayitbos(() {}, "TAMAM", DialogType.error, "Bir Hata",
                            Colors.red, "Hata", null, context);
  }

  void bakimFormuButton(
    String? _durumu,
    BuildContext context,
    String? _ilceDegisim,
  ) {
    _durumu == "Beklemede"
        ? kayitbos(() {}, "TAMAM", DialogType.error, "Önce İşleme Almalısınız",
            Colors.red, "Hata", null, context)
        : projectFiltered!.sonucAciklama == ""
            ? kayitbos(() {}, "TAMAM", DialogType.error,
                "Sonuç Açıklama Boş Olamaz!", Colors.red, "Hata", null, context)
            : projectFiltered!.sonucAciklama == null &&
                    sonucAciklamaKayit == null
                ? kayitbos(
                    () {},
                    "TAMAM",
                    DialogType.error,
                    "Sonuç Açıklama Boş Olamaz!",
                    Colors.red,
                    "Hata",
                    null,
                    context)
                : _ilceDegisim == null && gelenIlce.isEmpty
                    ? kayitbos(() {}, "TAMAM", DialogType.error,
                        "İlçe Boş Olamaz!", Colors.red, "Hata", null, context)
                    : _ilceDegisim == "null"
                        ? kayitbos(
                            () {},
                            "TAMAM",
                            DialogType.error,
                            "İlçe Boş Olamaz!",
                            Colors.red,
                            "Hata",
                            null,
                            context)
                        : (getPersonel.isNotEmpty == true)
                            ? Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Bakim(
                                    idPbsKisi: widget.yetkiler.idPbsKisi,
                                    //      durumuTamamlandi: finished,
                                    idBatAriza: projectFiltered!.id,
                                    ustTuru: gelenUstTur,
                                    formTuru: "BAKIM",
                                    idSisKullaniciGuncelleyen:
                                        widget.yetkiler.idKullanici,
                                    idSisKullaniciKaydeden:
                                        widget.yetkiler.idKullanici,
                                    ipAdresi: widget.ipAdresi,
                                    gelenilce: bolgeAdi,
                                    gelenListe: getPersonel,
                                    idKbsOrgut: widget.yetkiler.idKbsOrgut!,
                                  ),
                                ),
                              )
                            : kayitbos(() {}, "TAMAM", DialogType.error,
                                "Bir Hata", Colors.red, "Hata", null, context);
  }

//? KAYDET BUTON
  Future<void> kaydetButton(
      // TextEditingController _telefon,
      // TextEditingController _aciklama,
      // TextEditingController _bildirim_tarihi,
      String? _durumu) async {
    setState(() {
      // isLoadingKaydet = true;
      // telefon = _telefon.text;
      // aciklama = _aciklama.text;
      //sonucAciklama = deneme.text;
      //  exBildirim = _bildirim_tarihi.text;

      // onay = "HAYIR";
      //          debugPrint("filename :" + fileName);
      //   debugPrint("dosyacik :" + dosyacik);
      // debugPrint("base64file :" + base64File.toString());
      switch (durumuKayit) {
        // case "TEKNIK_DESTEK":
        case "Beklemede":
          {
            durumuKayit = "BEKLEMEDE";
          }
          break;
        case "Kullanıcı Onayında":
          {
            durumuKayit = "KULLANICI_ONAYINDA";
          }
          break;
        case "Kullanıcıdan Red":
          {
            durumuKayit = "KULLANICIDAN_RED";
          }
          break;
        case "Tamamlandı":
          {
            durumuKayit = "TAMAMLANDI";
          }
          break;
        case "Yönetici Onayında":
          {
            durumuKayit = "YONETICI_ONAYINDA";
          }
          break;
        case "Yöneticiden Red":
          {
            durumuKayit = "YONETICIDEN_RED";
          }
          break;
        case "İleri Tarihe Planlandı":
          {
            durumuKayit = "ILERI_TARIHE_PLANLANDI";
          }
          break;
        case "İptal":
          {
            durumuKayit = "IPTAL";
          }
          break;
        case "İşleme Alındı":
          {
            durumuKayit = "ISLEME_ALINDI";
          }
          break;
        // default:
        //   {
        //     gelenDurumuSwitch = gelenDurumu;
        //   }
        // break;
      }
    });

    await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(pushData(buttonTypes.kaydet),
          message: Text('Lütfen Bekleyiniz...')),
    );

    kayitbos(
      () {
        // setState(() {
        //   // isKayitBasariliMi = true;
        //   super.widget;
        //   ref.refresh(arizaListesiProvider(widget.userName!).future);
        // });
      },
      "TAMAM",
      DialogType.success,
      "Kayıt işlemi gerçekleştirilmiştir.",
      Colors.lightGreen,
      "Onay",
      null,
      context,
    );
  }

  Future<void> islemleriTamamlaButton(
      String? _aciklama, BuildContext context, String? _durumu) async {
    String formattedDate =
        DateFormat('dd-MM-yyyy – kk:mm').format(DateTime.now());
    bildirimTarihiNowKayit = formattedDate;

    // _durumu == "Beklemede"
    //     ? kayitbos(() {}, "TAMAM", DialogType.error, "Önce İşleme Almalısınız",
    //         Colors.red, "Hata", null, context)
    //     : cozumTuruIdKayit == null
    //         ? kayitbos(() {}, "TAMAM", DialogType.error,
    //             "Çözüm Alanı Boş Olamaz", Colors.red, "Hata", null, context)
    //         : arizaNedeniIdKayit == null
    //             ? kayitbos(
    //                 () {},
    //                 "TAMAM",
    //                 DialogType.error,
    //                 "Arıza Nedeni Boş Olamaz",
    //                 Colors.red,
    //                 "Hata",
    //                 null,
    //                 context)
    //             : sonucIdKayit == null
    //                 ? kayitbos(
    //                     () {},
    //                     "TAMAM",
    //                     DialogType.error,
    //                     "Sonuç Türü Boş Olamaz",
    //                     Colors.red,
    //                     "Hata",
    //                     null,
    //                     context)
    //                 // TODO: Buradak KALDIK
    //                 : sonucAciklamaKayit == null || sonucAciklamaKayit == ""
    //                     ? kayitbos(
    //                         () {},
    //                         "TAMAM",
    //                         DialogType.error,
    //                         "Sonuç Açıklama Boş olamaz",
    //                         Colors.red[300],
    //                         "Hata",
    //                         null,
    //                         context)
    //                     : sonucAciklamaKayit.trim().length < 7
    //                         ? kayitbos(
    //                             () {},
    //                             "TAMAM",
    //                             DialogType.error,
    //                             "Sonuç Açıklama Alanı 7 karakterden küçük olamaz",
    //                             Colors.red[300],
    //                             "Hata",
    //                             null,
    //                             context)
    //                         : null;
    if (_durumu == "Beklemede") {
      kayitbos(() {}, "TAMAM", DialogType.error, "Önce İşleme Almalısınız",
          Colors.red, "Hata", null, context);
    } else if (cozumTuruIdKayit == null && _selectedCozumTuru == null) {
      kayitbos(() {}, "TAMAM", DialogType.error, "Çözüm Alanı Boş Olamaz",
          Colors.red, "Hata", null, context);
    } else if (arizaNedeniIdKayit == null && _selectedArizaNedeni == null) {
      kayitbos(() {}, "TAMAM", DialogType.error, "Arıza Nedeni Boş Olamaz",
          Colors.red, "Hata", null, context);
    } else if (sonucIdKayit == null && _selectedSonucTuru == null) {
      kayitbos(() {}, "TAMAM", DialogType.error, "Sonuç Türü Boş Olamaz",
          Colors.red, "Hata", null, context);
    } else if (sonucAciklamaKayit == null || sonucAciklamaKayit == "") {
      kayitbos(() {}, "TAMAM", DialogType.error, "Sonuç Açıklama Boş olamaz",
          Colors.red[300], "Hata", null, context);
    } else if (sonucAciklamaController.text == null ||
        sonucAciklamaController.text == "") {
      kayitbos(() {}, "TAMAM", DialogType.error, "Sonuç Açıklama Boş olamaz",
          Colors.red[300], "Hata", null, context);
    } else if (sonucAciklamaKayit!.trim().length < 7) {
      kayitbos(
          () {},
          "TAMAM",
          DialogType.error,
          "Sonuç Açıklama Alanı 7 karakterden küçük olamaz",
          Colors.red[300],
          "Hata",
          null,
          context);
    } else {
      setState(
        () {
          //  sonucIdKayit = _selectedSonucTuru.id.toString();

          // isLoadingKaydet = true;
          // telefon = _telefon.text;
          // aciklama = _aciklama.text;
          //  sonucAciklamaKayit = _sonucAciklamaController.text;
          // exBildirim = _bildirim_tarihi.text;

          durumuKayit = "TAMAMLANDI";
          onayKayit = "EVET";
          // bildirimTarihiNowKayit = bildirimTarihiNow;
          idPersonelOnaylayanKayit = widget.yetkiler.idPbsKisi.toString();
        },
      );

      debugPrint("GELEN DATA   ${projectFiltered!.id}");

      await showDialog(
          context: context,
          builder: (context) {
            return FutureProgressDialog(
              pushData(buttonTypes.tamamla),
              message: Text('Lütfen Bekleyiniz...'),
            );
          });

      kayitbos(
        () {
          // isKayitBasariliMi = true;
          super.widget;
          Navigator.pop(context);
          // ref.invalidate(getFaultsProvider(username: widget.userName!));
          // Navigator.pop(context, (value) {
          //   print(value);
          //   ref.read(getFaultsProvider(
          //           username: widget.userName!, isAtanan: isAtananString!)
          //       .future);

          // });

          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) =>
          //           //    anaSayfa( locationText: username, sifText: pass,),

          //           TabsRiverpod(
          //         token: widget.token,
          //         locationText: widget.userName,
          //         yetkiler: widget.yetkiler,
          //       ),
          //     ));
        },
        "TAMAM",
        DialogType.success,
        "Kayıt işlemi gerçekleştirilmiştir.",
        Colors.lightGreen,
        "Onay",
        null,
        context,
      );
    }
  }

  String? listRoute2;

  Future<bool> pushData(Enum buttonTuru) async {
    // isLoadingKaydet = false;
    String resMesaj;
    var parse;
    bool isSaved = false;
    parse = await http.post(
        Uri.parse(
            sabitler.Constants.url_ybs + sabitler.Constants.url_ariza_kayit),
        body: jsonEncode({
          "id": arizayiCogaltVisibility != true ? projectFiltered!.id : 0,
          "kullaniciAdi": widget.userName,
          "idBatArizaTuru": gidenArizaTuru == null
              ? projectFiltered!.idBatArizaTuru
              : gidenArizaTuru,
          "telefon": projectFiltered!.telefon,
          "gsm": projectFiltered!.gsm,
          "aciklama": projectFiltered!.aciklama,
          "arizaUstTuru":
              gidenUstTur == null ? projectFiltered!.arizaUstTuru : gidenUstTur,
          "bildirimTarihi": projectFiltered!.bildirimTarihi,
          "durumu": durumuKayit, //Kendisi ekliyor
          "arizaTuru": null, //Kendisi ekliyor
          "sonuc": null, //null
          "sonucId": sonucIdKayit == null
              ? _selectedSonucTuru != null
                  ? _selectedSonucTuru!.id != null
                      ? _selectedSonucTuru!.id
                      : null
                  : null
              : sonucIdKayit,

          //null
          "sonucAciklama": sonucAciklamaKayit, //null
          "base64ImageList": sendingImageList, //base64,
          "idAbsIlce": ilceKayit == null
              ? gelenIlce == null
                  ? null
                  : gelenIlce.isEmpty
                      ? null
                      : gelenIlce[0].value
              : ilceKayit, //gelenIlceid,

          "idSbsKurumMuhtarlik": muhtarlikKayitId == null
              ? _selectedMuhtarlik != null
                  ? _selectedMuhtarlik!.sbsMuhatapId != null
                      ? _selectedMuhtarlik!.sbsMuhatapId
                      : null
                  : null
              : muhtarlikKayitId, //_muhtarlik,

          "base64FileList": null, //base64File,
          "email": projectFiltered!.email ?? "",
          "alternatifEmail": null, //null
          "base64FileName": null, //fileName,
          "cozumTuruId": cozumTuruIdKayit == null
              ? _selectedCozumTuru != null
                  ? _selectedCozumTuru!.kodu != null
                      ? _selectedCozumTuru!.kodu
                      : null
                  : null
              : cozumTuruIdKayit,

          // cozumTuruValue, //null
          "arizaNedeniId": arizaNedeniIdKayit == null
              ? _selectedArizaNedeni != null
                  ? _selectedArizaNedeni!.kodu != null
                      ? _selectedArizaNedeni!.kodu
                      : null
                  : null
              : arizaNedeniIdKayit,

          //arizaNedenivalue, //null
          "arizaNedeni": null, //null
          "idPbsPersonel": null, //null-- İŞLEMİ YAPAN a kayıt atıyor
          "personelAdSoyad": null,
          "personelOrgut": null, //null
          "pbsPersonelIslemeAlan":
              // pbsPersonelIslemeAlan, //null ID_PBS_PER_ISLEME_ALAN alanına yazmıyor
              widget.yetkiler.idPbsKisi,

          "pbsPersonelBildiren":
              pbsPersonelBildirenKayit, // Başlatan kullanıcı ismi
          "pbsPersonelBildirenOrgut": null, //kendisi ekliyor

          //! TODO: Bitiş tarihini setlemiyor
          "bitisTarihi": bitisTarihiKayit,
          "idBatArizaBildirimTuru": "101",
          "onay": onayKayit,
          //! TODO: ÇÖZÜM SÜRESİ ve İŞLEM sSÜRESİ setlenmiyor
          "cozumSuresi": null,
          "islemSuresi": null,
          "idPbsPersonelOnaylayan": idPersonelOnaylayanKayit,
          "idSisKullaniciGuncelleyen": widget.yetkiler.idKullanici,
          "idPbsPersonelIslemYapan": idPbsPersonelIslemYapanKayit, //221914863
          "idPbsPersonelIslemYapanIki": idPbsPersonelIslemYapanIkiKayit,
          "idPbsPersonelIslemYapanUc": idPbsPersonelIslemYapanUcKayit,
          "idPbsPersonelIslemYapanDort": idPbsPersonelIslemYapanDortKayit,
        }),
        headers: {
          'Authorization': sabitler.Constants.auth,
          //  "Accept": "application/json"
          // "Content-Type": "application/json"
        });

    // List<Ariza> allPostsFromJson(String str) {
    resMesaj = parse.body;
    //print(res_mesaj);

    if (resMesaj == "Basvuru Islemi Basarili") {
      if (buttonTuru == buttonTypes.tamamla ||
          buttonTuru == buttonTypes.baskaServiseAta) {
        await ref.refresh(getFaultsProvider(
                username: widget.userName!, isAtanan: isAtananString!)
            .future);
      }

      debugPrint("başarılı");
      isSaved = true;
      isKayitBasariliMi = true;
      super.widget;
      // ref.invalidate(getFaultsProvider(username: widget.userName!));
      // ref.refresh(getFaultsProvider(username: widget.userName!).future);

      // kayitbos(
      //   () {
      //     setState(() {
      //       isKayitBasariliMi = true;
      //       super.widget;
      //       ref.refresh(arizaListesiProvider(widget.userName).future);
      //     });

      //     // Navigator.push(
      //     //     context,
      //     //     MaterialPageRoute(
      //     //       builder: (context) => Tabs2(
      //     //         locationText: widget.userId,
      //     //         arizaAdmin: widget.arizaAdmin2,
      //     //         arizaAtanan: widget.arizaAtanan2,
      //     //         arizaAtayan: widget.arizaAtayan2,
      //     //         arizaGenclikPortal: widget.arizaGenclikPortal2,
      //     //         arizaGenclikYbs: widget.arizaGenclikYbs2,
      //     //         arizaBilgiIslem: widget.arizaBilgiIslem2,
      //     //         arizaYetkisiz: widget.arizaYetkisiz2,
      //     //         idKullanici: widget.idKullanici,
      //     //         idPbsKisi: widget.idPbsKisi,
      //     //         idSbsKisi: widget.idSbsKisi,
      //     //         titleName: widget.titleName,
      //     //       ),
      //     //     ));

      //     // Navigator.pushReplacement(
      //     //   context,
      //     //   MaterialPageRoute(builder: (BuildContext context) => super.widget),
      //     // );
      //   },
      //   "TAMAM",
      //   DialogType.success,
      //   "Kayıt işlemi gerçekleştirilmiştir.",
      //   Colors.lightGreen,
      //   "Onay",
      //   null,
      //   context,
      // );

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     width: 55,
      //     content: Text("KAYIT BAŞARILI"),
      //   ),
      // );

      //     ref.invalidate(arizaListesiProvider);
      //     setState(() {
      //       isChanged = true;
      //       print("kayıt başarılı");
      //     });
      //   // } else {
      //   //   Map mapRes = json.decode(parse.body);
      //   //   print('Response from server: $mapRes');
      //   //   // setState(() {
      //   //   String listRoute2 = mapRes['resultMessage'];

      //   //   ScaffoldMessenger.of(context)
      //   //       .showSnackBar(SnackBar(content: Text("$listRoute2 ")));

      //   //   //  super.widget;
    } else {
      isSaved = false;
      Map mapRes = json.decode(parse.body);
      debugPrint('Response from server: $mapRes');
      // debugPrint(() {
      String listRoute2 = mapRes['resultMessage'];

      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text("$listRoute2 ")));

      //  super.widget;
    }
    return isSaved;
  }
}
 
 */
