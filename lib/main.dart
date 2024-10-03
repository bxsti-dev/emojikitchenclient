// import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter_svg/flutter_svg.dart';


void main()async {
  runApp(const MyApp());
} 

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(
        onThemeChanged: (themeMode) {
          setState(() {_themeMode = themeMode;});
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}



class Home extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  const Home({super.key, required this.onThemeChanged});

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  final emojis = ['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😭', '😉', '😗', '😙', '😚', '😘', '🥰', '😍', '🤩', '🥳', '🫠', '🙃', '🙂', '🥲', '🥹', '😊', '😌', '😏', '😴', '😪', '🤤', '😋', '😛', '😝', '😜', '🤪', '🥴', '😔', '🥺', '😬', '😑', '😐', '😶', '🫥', '🤐', '🫡', '🤔', '🤫', '🫢', '🤭', '🥱', '🤗', '🫣', '😱', '🤨', '🧐', '😒', '🙄', '😮', '💨', '😤', '😠', '😡', '🤬', '😞', '😓', '😟', '😥', '😢', '🙁', '🫤', '😕', '😰', '😨', '😧', '😦', '😯', '😲', '😳', '🤯', '😖', '😣', '😩', '😫', '😵', '🥶', '🥵', '🤢', '🤮', '🤧', '🤒', '🤕', '😷', '🤥', '😇', '🤠', '🤑', '🤓', '😎', '🥸', '🤡', '😈', '👿', '👻', '🎃', '💩', '🤖', '👽', '👾', '🌛', '🌜', '🌞', '🔥', '💯', '💫', '⭐', '🌟', '💥', '🙈', '🧡', '💛', '💚', '🩵', '💙', '💜', '🤎', '🖤', '🩶', '🤍', '🩷', '💘', '💝', '💖', '💗', '💓', '💞', '💕', '💌', '♥️', '🩹', '💔', '💋', '🦠', '💀', '🫦', '👍', '🪂', '💐', '🌹', '🌷', '🌸', '💮', '🌼', '🍄', '🌵', '🌲', '🪵', '🪨', '⛄', '🌋', '🌄', '🌈', '🌊', '🌍', '🐵', '🦁', '🐯', '🐱', '🐶', '🐺', '🐻', '🐨', '🐼', '🐭', '🐰', '🦊', '🦝', '🐮', '🐷', '🦄', '🐢', '🐸', '🐩', '🐐', '🦌', '🦙', '🦥', '🦔', '🦇', '🐦', '🐔', '🦉', '🪿', '🐧', '🦈', '🐳', '🐟', '🐙', '🦂', '🐌', '🐝', '🍓', '🍒', '🍉', '🍊', '🍍', '🍌', '🍋', '🥑', '🍞', '🧀', '🌭', '🍥', '🎂', '🧁', '🍬', '🧊', '🧃', '☕', '🛑', '⛽', '🛸', '🌇', '🎊', '🎈', '🎁', '🎆', '🥇', '🥈', '🥉', '🏆', '⚽', '🏀', '🏈', '🥅', '🎿', '🎣', '🎳', '🧩', '🎰', '🪄', '🎧', '🎬', '📟', '💾', '💻', '💡', '👑', '☂️', '💎', '📚', '📰', '🔮', '🏺', '🪤', '💬'];

  late var firstEmoji = emojis[Random().nextInt(43)];
  late var secondEmoji = emojis[Random().nextInt(43)];

  var imagePath = "";
  late Uint8List imageBytes;

  var clickedFavoriteIcon = false;
  var favoriteList = [];

  bool randomButton = false;

  loadSettings()async{
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path); //init
    var box = await Hive.openBox("save"); //create/open box

    if(box.get("darkmode") == null){
      box.put("darkmode",true);
    }else{
      if(box.get("darkmode") == true){
        widget.onThemeChanged(ThemeMode.dark);
      }
      if(box.get("darkmode") == false){
        widget.onThemeChanged(ThemeMode.light);
      }
    }
    if(box.get("randomButton") == null){
      box.put("randomButton",false);
    }else{
      if(box.get("randomButton") == true){
        setState(() {randomButton = true;});
      }
      if(box.get("randomButton") == false){
        setState(() {randomButton = false;});
      }
    }
    
  }

  loadFavorites()async{
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path); //init
    var box = await Hive.openBox("save"); //create/open box

    if(box.get("favoriteList") == null){
      box.put("favoriteList",[]);
    }
    favoriteList = box.get("favoriteList");
    print(favoriteList);
  }

  saveFavorite()async{
    Hive.init("save"); //init
    var box = await Hive.openBox("save"); //create/open box

    favoriteList.add("https://emojik.vercel.app/s/${firstEmoji}_$secondEmoji?size=512");

    box.put("favoriteList",favoriteList);

  }

  removeFavorite()async{
    Hive.init("save"); //init
    var box = await Hive.openBox("save"); //create/open box

    favoriteList.remove("https://emojik.vercel.app/s/${firstEmoji}_$secondEmoji?size=512");

    box.put("favoriteList",favoriteList);
  }

  showSnackbar(String text, [bool favoritesButton = false]){
      if(favoritesButton == true){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),),
          action: SnackBarAction(label: "show favorites", onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesPage()));},),
        ));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),),
          showCloseIcon: true,
        ));   
      }
  }

  share()async{
    try{
      await getData();
      await Share.shareXFiles([XFile(imagePath)]);
    }finally{}
  } 

  save()async{
    try{
      await getData();

      if(Platform.isAndroid){
        ImageGallerySaver.saveImage(imageBytes);
        showSnackbar('Saved image to gallery!');
      }
      if(Platform.isWindows){
        String? output = await FilePicker.platform.saveFile(
          dialogTitle: 'select file location',
          fileName: "emoji.png",
          bytes: imageBytes
        );
        if(output != null){
          File(output).writeAsBytesSync(imageBytes);
        }
      }
    }finally{}
  }

  getData()async{
    final response = await http.get(Uri.parse("https://emojik.vercel.app/s/${firstEmoji}_$secondEmoji?size=512"));
    final bytes = response.bodyBytes;
    final temp = await getDownloadsDirectory();
    final path = "${temp?.path}/emoji_${emojis.indexOf(firstEmoji)}+${emojis.indexOf(secondEmoji)}.png";
    imagePath = path;
    imageBytes = bytes;
    File(path).writeAsBytesSync(bytes);
  }

  @override
  void initState() { //run once
    super.initState();
    loadFavorites();
    loadSettings();
  }
  @override
  Widget build(BuildContext context) {

    if(favoriteList.contains("https://emojik.vercel.app/s/${firstEmoji}_$secondEmoji?size=512") == true){
      setState(() {clickedFavoriteIcon = true;});
    }else{
      setState(() {clickedFavoriteIcon = false;});
    }

    double sWidth = MediaQuery.of(context).size.width;
    //double sHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text('Emojikitchen Client'), centerTitle: true, actions: [
        IconButton(onPressed: ()async{
          final navigation = await Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesPage()));
          if(navigation != null){
            if(navigation != "NO_FAVORITE"){
              setState(() {
                firstEmoji = String.fromCharCode(int.parse(navigation.split(",")[0]));
                secondEmoji = String.fromCharCode(int.parse(navigation.split(",")[1]));
              });
            }else{
              setState(() {
                clickedFavoriteIcon = false;
              });
            }
          }
        },icon: const Icon(Icons.favorite_border)),
        IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(onThemeChanged: widget.onThemeChanged,)));},icon: const Icon(Icons.settings_outlined)),
      ]),
      body: Center(
        child: Column(
          children: [

            //////////////////////////////////////////////////////////////////////////////////////////
            const Spacer(flex: 1),

            SizedBox(
              width: 255,//sWidth/2,
              height: 255,//sWidth/2,
              child: GestureDetector(
                onLongPress: () {
                  setState(() {
                    firstEmoji = emojis[Random().nextInt(43)];
                    secondEmoji = emojis[Random().nextInt(43)];
                  });
                },
                child: Image.network("https://emojik.vercel.app/s/${firstEmoji}_$secondEmoji?size=255"),),  //https://emojik.vercel.app/s/1f979_1f617?size=${sWidth.toInt()/2}
            ),  



            //////////////////////////////////////////////////////////////////////////////////////////
            const Spacer(flex: 1),

            Row(children: [
              const Spacer(flex: 5),
              ElevatedButton(onPressed: (){share();},child: 
                const Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                  Padding(padding: EdgeInsets.only(left: 8.0),),
                  Icon(Icons.share_outlined),
                  Padding(padding: EdgeInsets.all(3.0),),
                  Text("Share"),
                  Padding(padding: EdgeInsets.only(right: 8.0)),
                ]),
              ),
              const Spacer(flex: 5),
            ]),

            const Padding(padding: EdgeInsets.all(8.0),),

            Row(mainAxisAlignment: MainAxisAlignment.center,children: [
              ElevatedButton.icon(onPressed: (){

                if(clickedFavoriteIcon == false){
                  saveFavorite();
                  showSnackbar("emoji saved to favorites", true);
                }else{
                  removeFavorite();
                }
                
                setState(() {
                  clickedFavoriteIcon = !clickedFavoriteIcon;
                });
                },
                label: Icon(clickedFavoriteIcon ? Icons.favorite : Icons.favorite_border)
              ),
              const Padding(padding: EdgeInsets.all(5.0)),
              ElevatedButton.icon(onPressed: (){save();}, label: const Icon(Icons.download_outlined)),
            ]),





            //////////////////////////////////////////////////////////////////////////////////////////
            const Spacer(flex: 3),

            Row(mainAxisAlignment: MainAxisAlignment.center,children: [
              Card(elevation: 20,
                child: InkWell(onTap: () async {
                  final navigation = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ChooseEmoji()));
                  if(navigation != null){
                    setState(() {
                      firstEmoji = navigation;
                    });
                  }
                },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(padding: const EdgeInsets.all(15),constraints: const BoxConstraints(maxHeight: 155, maxWidth: 155),width: sWidth*0.35,height: sWidth*0.35,
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(firstEmoji, style: const TextStyle(fontFamily: "NotoColorEmoji")),
                    ),
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.all(sWidth*0.03)),

              Card(elevation: 20,
                child: InkWell(onTap: () async {
                    final navigation = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ChooseEmoji()));
                    if(navigation != null){
                      setState(() {
                        secondEmoji = navigation;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(padding: const EdgeInsets.all(15),constraints: const BoxConstraints(maxHeight: 155, maxWidth: 155),width: sWidth*0.35,height: sWidth*0.35,
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(secondEmoji, style: const TextStyle(fontFamily: "NotoColorEmoji")),
                    ),
                  ),
                ),
              ),
            ]),

            if(randomButton) Card(
              margin: EdgeInsets.only(left: (sWidth/4)+(sWidth/7), right: (sWidth/4)+(sWidth/7), top: 20),
              elevation: 20,
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                onTap: () {
                  setState(() {
                    firstEmoji = emojis[Random().nextInt(43)];
                    secondEmoji = emojis[Random().nextInt(43)];
                  });
                },
                //child: Padding(padding: const EdgeInsets.all(10), child: Center(child: SvgPicture.asset("random.svg", color: Colors.grey,height: 40,))),
                child: const Padding(padding: EdgeInsets.all(10), child: Center(child: Text("Random"))),
              ),
            ),


            randomButton ? const Spacer(flex: 2) 
            : const Spacer(flex: 3), //3
            
                


          ]
        )
      )
    );
  }
}





//////////////////////////////////////////////////////////////////////////////////////////
class ChooseEmoji extends StatefulWidget {
  const ChooseEmoji({super.key});

  @override
  State<ChooseEmoji> createState() => _ChooseEmojiState();
}

class _ChooseEmojiState extends State<ChooseEmoji> {
  final emojis = ['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😭', '😉', '😗', '😙', '😚', '😘', '🥰', '😍', '🤩', '🥳', '🫠', '🙃', '🙂', '🥲', '🥹', '😊', '😌', '😏', '😴', '😪', '🤤', '😋', '😛', '😝', '😜', '🤪', '🥴', '😔', '🥺', '😬', '😑', '😐', '😶', '🫥', '🤐', '🫡', '🤔', '🤫', '🫢', '🤭', '🥱', '🤗', '🫣', '😱', '🤨', '🧐', '😒', '🙄', '😮', '💨', '😤', '😠', '😡', '🤬', '😞', '😓', '😟', '😥', '😢', '🙁', '🫤', '😕', '😰', '😨', '😧', '😦', '😯', '😲', '😳', '🤯', '😖', '😣', '😩', '😫', '😵', '🥶', '🥵', '🤢', '🤮', '🤧', '🤒', '🤕', '😷', '🤥', '😇', '🤠', '🤑', '🤓', '😎', '🥸', '🤡', '😈', '👿', '👻', '🎃', '💩', '🤖', '👽', '👾', '🌛', '🌜', '🌞', '🔥', '💯', '💫', '⭐', '🌟', '💥', '🙈', '🧡', '💛', '💚', '🩵', '💙', '💜', '🤎', '🖤', '🩶', '🤍', '🩷', '💘', '💝', '💖', '💗', '💓', '💞', '💕', '💌', '♥️', '🩹', '💔', '💋', '🦠', '💀', '🫦', '👍', '🪂', '💐', '🌹', '🌷', '🌸', '💮', '🌼', '🍄', '🌵', '🌲', '🪵', '🪨', '⛄', '🌋', '🌄', '🌈', '🌊', '🌍', '🐵', '🦁', '🐯', '🐱', '🐶', '🐺', '🐻', '🐨', '🐼', '🐭', '🐰', '🦊', '🦝', '🐮', '🐷', '🦄', '🐢', '🐸', '🐩', '🐐', '🦌', '🦙', '🦥', '🦔', '🦇', '🐦', '🐔', '🦉', '🪿', '🐧', '🦈', '🐳', '🐟', '🐙', '🦂', '🐌', '🐝', '🍓', '🍒', '🍉', '🍊', '🍍', '🍌', '🍋', '🥑', '🍞', '🧀', '🌭', '🍥', '🎂', '🧁', '🍬', '🧊', '🧃', '☕', '🛑', '⛽', '🛸', '🌇', '🎊', '🎈', '🎁', '🎆', '🥇', '🥈', '🥉', '🏆', '⚽', '🏀', '🏈', '🥅', '🎿', '🎣', '🎳', '🧩', '🎰', '🪄', '🎧', '🎬', '📟', '💾', '💻', '💡', '👑', '☂️', '💎', '📚', '📰', '🔮', '🏺', '🪤', '💬'];

  @override
  Widget build(BuildContext context) {
    //double sWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Emoji"),centerTitle: true,leading: IconButton(onPressed: () async {Navigator.pop(context,null);}, icon: const Icon(Icons.arrow_back))),
      body: GridView.count(
        crossAxisCount: 6,
        children: [
          for(var i=0;i<emojis.length;i++)
            Card(elevation: 20,child: 
              InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: () async {Navigator.pop(context,emojis[i]);},
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(emojis[i], style: const TextStyle(fontFamily: "NotoColorEmoji")),
                ),
              ),
            )

        ],
      )
    );
  }
}





//////////////////////////////////////////////////////////////////////////////////////////

class SettingsPage extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = true;
  bool randomButton = false;

  loadSettings()async{
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path); //init
    var box = await Hive.openBox("save"); //create/open box

    if(box.get("darkmode") == null){
      box.put("darkmode",true);
    }else{
      if(box.get("darkmode") == true){
        widget.onThemeChanged(ThemeMode.dark);
        setState(() {darkMode = true;});
      }
      if(box.get("darkmode") == false){
        widget.onThemeChanged(ThemeMode.light);
        setState(() {darkMode = false;});
      }
    }
    if(box.get("randomButton") == null){
      box.put("randomButton",false);
    }else{
      if(box.get("randomButton") == true){
        setState(() {randomButton = true;});
      }
      if(box.get("randomButton") == false){
        setState(() {randomButton = false;});
      }
    }

  }
  

  @override
  void initState() { //run once
    super.initState();
    loadSettings();
  }
  @override
  Widget build(BuildContext context) {
    //double sWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true, leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back)), actions: [IconButton(onPressed: (){
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text("About"),
            contentPadding: const EdgeInsets.all(20),
            children: [
              const Text("This app is built with Flutter \n\nPowered by the Emoji Kitchen API"),
              InkWell(
                child: const Text("https://emojik.vercel.app",style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                onTap: () {try{launchUrl(Uri.parse("https://emojik.vercel.app"));}finally{}},
              ),
              const Text("\n\nApp developed by bxsti-dev"),
              InkWell(
                child: const Text("github.com/bxsti-dev/emojikitchenclient",style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                onTap: () {try{launchUrl(Uri.parse("https://github.com/bxsti-dev/emojikitchenclient"));}finally{}},
              ),
              TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Close")),
            ],
          ),
        );
      }, icon: const Icon(Icons.info_outline))],),
      body: Column(children: [
        ListTile(title: const Text("Dark mode"),trailing: 
          Switch(value: darkMode, 
                onChanged: (value) async{
                  final directory = await getApplicationDocumentsDirectory();
                  Hive.init(directory.path); //init
                  var box = await Hive.openBox("save"); //create/open box

                  setState(() {
                    darkMode = value;
                    if(darkMode == true){
                       widget.onThemeChanged(ThemeMode.dark);
                       box.put("darkmode", true);
                    }else{
                      widget.onThemeChanged(ThemeMode.light);
                      box.put("darkmode", false);
                    }
                  }
                );})),
        const Divider(),
        ListTile(title: const Text("Random Button"),trailing: 
          Switch(value: randomButton, 
                onChanged: (value) async{
                  final directory = await getApplicationDocumentsDirectory();
                  Hive.init(directory.path); //init
                  var box = await Hive.openBox("save"); //create/open box

                  setState(() {
                    randomButton = value;
                    if(randomButton == true){
                      box.put("randomButton", true);
                    }else{
                      box.put("randomButton", false);
                    }
                  });

                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text("Restart Required"),
                      contentPadding: const EdgeInsets.all(20),
                      children: [
                        const Text("Restart the app to save changes"),
                        TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Okay"))
                      ],
                    ),
                  );

                })),
      ],)
    );
  }
}





//////////////////////////////////////////////////////////////////////////////////////////

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  var favoriteList = [];
  loadFavorites()async{
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path); //init
    var box = await Hive.openBox("save"); //create/open box

    if(box.get("favoriteList") == null){
      box.put("favoriteList",[]);
    }
    setState(() {
      favoriteList = box.get("favoriteList");
    });

    print(favoriteList);
  }

  removeFavorite(int index)async{
    try{
      Vibration.vibrate(duration: 12);
    }finally{}

    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path); //init
    var box = await Hive.openBox("save"); //create/open box

    setState(() {
      favoriteList.removeAt(index);
      box.put("favoriteList", favoriteList);
    });
  }

  @override
  void initState() { //run once
    super.initState();
    loadFavorites();
  }
  @override
  Widget build(BuildContext context) {
    //double sWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites"), centerTitle: true, leading: IconButton(onPressed: (){Navigator.pop(context,"NO_FAVORITE");}, icon: const Icon(Icons.arrow_back))),
      body: favoriteList.isNotEmpty ? GridView.count(
        crossAxisCount: 2,
        children: [

          for(var i = 0;i<favoriteList.length;i++)
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: (){  
                    var first = favoriteList[i].split("_")[0].runes.toString().replaceAll(")", "").split(",").last.trimLeft();
                    var second = favoriteList[i].split("_")[1].runes.toString().replaceAll("(","").split(",").first;

                    Navigator.pop(context,"$first,$second");
                  },
                  child: Stack(children: [
                    Align(alignment: Alignment.topRight, child: IconButton(onPressed: (){removeFavorite(i);}, icon: const Icon(Icons.close))),  
                    Align(alignment: Alignment.center, child: Padding(padding: const EdgeInsets.all(25),child: Image.network(favoriteList[i])))
                  ],),
                ),

            ),
        ]
      ):const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: [
            Icon(Icons.favorite_border),
            Padding(padding: EdgeInsets.all(10.0)),
            Text("You don't have any favorites yet.")
          ])
        ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////