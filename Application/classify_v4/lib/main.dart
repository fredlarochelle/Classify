import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:chengguo_audio_recorder_v2/audio_recorder.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';

String txt = "";
String txt_main = "Télécharge ou enregistre un extrait audio et le pouvoir de l'intelligence artificielle va déterminer le genre!";

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Classify",
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool audioBool = false;

  // La fonction qui upload le fichier audio à l'API
  void upload(File audioFile) async {
    var stream = new http.ByteStream(DelegatingStream.typed(audioFile.openRead()));
    var longueur = await audioFile.length();

    String base = "https://classify-api.onrender.com";

    var uri = Uri.parse(base + '/analyze');

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, longueur, filename: basename(audioFile.path));

    request.files.add(multipartFile);

    var response = await request.send();

    response.stream.transform(utf8.decoder).listen((prediction) {
      print(prediction);

      if(prediction == '{"result":"Electronic"}'){
        txt = "Électronique";
      }
      else if(prediction =='{"result":"Experimental"}'){
        txt = "Expérimentale";
      }
      else if(prediction =='{"result":"Folk"}'){
        txt = "Folk";
      }
      else if(prediction == '{"result":"Hip-Hop"}'){
        txt = "Hip-Hop";
      }
      else if(prediction == '{"result":"Instrumental"}'){
        txt = "Instrumentale";
      }
      else if(prediction == '{"result":"International"}'){
        txt = "International";
      }
      else if(prediction == '{"result":"Pop"}'){
        txt = "Pop";
      }
      else if(prediction == '{"result":"Rock"}'){
        txt = "Rock";
      }
      else{
        txt = prediction;
      }

      setState(() {});
    });
  }


  // La fonction qui enregistre ou selectionne un fichier audio
  void action(int a) async {
    audioBool = true;
    
    if (a == 0){
      File audio;
      var temp = await AudioRecorder.startRecord();

      txt = "Enregistrement en cours, veuillez patienter pour 5 secondes...";

      setState(() {});

      // enregistre pour 5 secondes
      Future.delayed(Duration(seconds: 5), () {
        AudioRecorder.stopRecord();

        audio = File(temp);

        txt = "Analyse en cours... Veuillez patienter...";
        debugPrint(audio.toString());
        upload(audio);

        setState(() {});
      });
    }
    else{
      File audio;
      audio = await FilePicker.getFile(type: FileType.audio);

      txt = "Analyse en cours... Veuillez patienter...";
      debugPrint(audio.toString());
      upload(audio);

      setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Classify"),
      ),
      body: new Container(
        child: Center(
          child: Column(
            children: <Widget>[
              audioBool == false
                  ? new Text(
                txt_main,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
              )
              : new Text(
                txt,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new Stack(
        children: <Widget>[
          Align(
              alignment: Alignment(1.0, 1.0),
              child: new FloatingActionButton(
                // enregistre
                onPressed: (){
                  action(0);
                },
                child: new Icon(Icons.mic),

              )
          ),
          Align(
              alignment: Alignment(1.0, 0.8),
              child: new FloatingActionButton(
                  onPressed: (){
                    // selectionne un fichier
                    action(1);
                  },
                  child: new Icon(Icons.file_upload)
              )
          ),

        ],
      ),
    );
  }
}
