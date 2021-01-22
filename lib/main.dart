import 'package:animationpractice/instaStories.dart';
import 'package:animationpractice/themeBloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  runApp(Main(
    child: MyApp(),
  ));
}

class Main extends StatelessWidget {
  final Widget child;

  const Main({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (BuildContext context) => ThemeBloc(), child: child);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var t = Provider.of<ThemeBloc>(context);
    return StreamBuilder<bool>(
        stream: t.darkTheme$,
        builder: (context, snapshot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            darkTheme: ThemeData(brightness: Brightness.dark),
            themeMode: (snapshot.data) ? ThemeMode.dark : ThemeMode.light,
            home: MyHomePage(title: 'Animation'),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Offset offset;
  bool showTarget = false;
  var showObj = true;
  Color targetColor = Colors.transparent;

  @override
  void initState() {
    offset = Offset(100, 100);
    super.initState();
  }

  double cHeight = 40;
  double cWidth = 40;

  onDragEnd(details, size) {
    var con1 = details.offset.dy < kToolbarHeight + 30;
    var con2 = details.offset.dy > size.height - cHeight;
    var con3 = details.offset.dx < 0;
    var con4 = details.offset.dx > size.width - cWidth;

    setState(() {
      showTarget = false;

      if (con1 || con2 || con3 || con4) {
        if (con1 && con3) {
          offset = Offset(0, kToolbarHeight + 30);
        } else if (con1 && con4) {
          offset = Offset(size.width - cWidth, kToolbarHeight + 30);
        } else if (con2 && con3) {
          offset = Offset(0, size.height - cHeight);
        } else if (con2 && con4) {
          offset = Offset(size.width - cWidth, size.height - cHeight);
        } else if (con1) {
          offset = Offset(details.offset.dx, kToolbarHeight + 30);
        } else if (con2) {
          offset = Offset(details.offset.dx, size.height - cHeight);
        } else if (con3) {
          offset = Offset(0, details.offset.dy);
        } else if (con4) {
          offset = Offset(size.width - cWidth, details.offset.dy);
        }
      } else {
        offset = Offset(details.offset.dx, details.offset.dy);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    var t = Provider.of<ThemeBloc>(context);
    Size size = MediaQuery.of(context).size;
    Widget first = AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: cHeight,
      width: cWidth,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          StreamBuilder<bool>(
              stream: t.darkTheme$,
              builder: (context, snapshot) {
                return IconButton(
                    icon: Icon(
                      (snapshot.data ? Icons.toggle_off : Icons.toggle_on),
                      color: snapshot.data ? Colors.grey : Colors.green,
                      size: 35,
                    ),
                    onPressed: () {
                      t.inDarkTheme(!snapshot.data);
                      print(snapshot.data);
                    });
              }),
          SizedBox(
            width: 8,
          ),
          IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Colors.green,
                size: 35,
              ),
              onPressed: () {
                if (showObj == false) {
                  setState(() {
                    offset = Offset(100, 100);
                    showObj = true;
                  });
                }
              }),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: (!showObj)
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sampleUsers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Stories(
                                  storiesIndex: index,
                                ))),
                    child: TopStoriesContainer(user: sampleUsers[index]));
              })
          : Stack(
              alignment: Alignment.center,
              children: [
                (!showObj)
                    ? Container()
                    : Positioned(
                        top: offset.dy - 80,
                        left: offset.dx,
                        child: GestureDetector(
                          onTap: () {
                            if (cHeight < 100 && cWidth < 100) {
                              setState(() {
                                cHeight = cHeight * 1.1;
                                cWidth = cWidth * 1.1;
                              });
                            }
                          },
                          onDoubleTap: () {
                            if (cHeight > 40 && cWidth > 40) {
                              setState(() {
                                cHeight = cHeight / 1.1;
                                cWidth = cWidth / 1.1;
                              });
                            }
                          },
                          child: Draggable<Color>(
                            data: Colors.red,
                            child: first,
                            feedback: first,
                            childWhenDragging: Container(),
                            onDragEnd: (d) {
                              onDragEnd(d, size);
                            },
                            onDragStarted: () {
                              setState(() {
                                showTarget = true;
                              });
                            },
                          ),
                        ),
                      ),
                (!showTarget)
                    ? Container()
                    : Positioned(
                        bottom: cHeight,
                        child: DragTarget<Color>(
                          onLeave: (data) {
                            targetColor = Colors.transparent;
                          },
                          onMove: (details) {
                            targetColor = Colors.red;
                            // setState(() {
                            // });
                          },
                          onAccept: (data) async {
                            setState(() {
                              targetColor = Colors.transparent;
                              showObj = false;
                            });
                          },
                          builder: (context, acceptedValue, rejectedValue) {
                            return Container(
                              height: cHeight,
                              width: cWidth,
                              decoration: BoxDecoration(
                                  color: targetColor,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.red, width: 1)),
                              child: Center(
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                      )
              ],
            ),
    );
  }
}

class TopStoriesContainer extends StatelessWidget {
  final UserModel user;

  const TopStoriesContainer({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var t = Provider.of<ThemeBloc>(context);
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 20),
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(user.imageUrl),
                fit: BoxFit.cover,
              ),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          StreamBuilder<bool>(
              stream: t.darkTheme$,
              builder: (context, s) {
                return Text(
                  user.userName,
                  style: TextStyle(
                    fontSize: 17,
                    color: s.data ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
        ],
      ),
    );
  }
}
