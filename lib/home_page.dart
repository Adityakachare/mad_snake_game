import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/blank_pixel.dart';
import 'package:first_app/food_pixel.dart';
import 'package:first_app/highscore_tile.dart';
import 'package:first_app/snake_pixel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  //Grid Dimensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  //game settings
  bool gameHasStarted = false;

  final _nameController = TextEditingController();

  //user score
  int currentScore = 0;

  //snake position
  List<int> snakePosition = [0, 1, 2];

  //snake direction is initially to the right
  var currentDirection = snake_Direction.RIGHT;

  //food position
  int foodPosition = 55;

  //highscore list
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(5)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  //Start Game
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        //keep the snake moving
        moveSnake();

        //check if game is over
        if (gameOver()) {
          timer.cancel();

          //display a message to the user
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('GAME OVER'),
                content: Column(
                  children: [
                    Text('Your Current Score is: ' + currentScore.toString()),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: 'Enter Your Name:'),
                    ),
                  ],
                ),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      submitScore();
                      newGame();
                    },
                    child: Text('Submit'),
                    color: Colors.pink,
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  void submitScore() {
    //get access to the collection
    var database = FirebaseFirestore.instance;

    //add data to firebase
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePosition = [0, 1, 2];
      foodPosition == 55;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    //making sure that the food is not where the snake is
    while (snakePosition.contains(foodPosition)) {
      foodPosition = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          //add a head
          //if snake is at the right wall, need to re-adjust
          if (snakePosition.last % rowSize == 9) {
            snakePosition.add(snakePosition.last + 1 - rowSize);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
        }
        break;
      case snake_Direction.LEFT:
        {
          //add a head
          //if snake is at the right wall, need to re-adjust
          if (snakePosition.last % rowSize == 0) {
            snakePosition.add(snakePosition.last - 1 + rowSize);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
        }
        break;
      case snake_Direction.UP:
        {
          //add a head
          if (snakePosition.last < rowSize) {
            snakePosition
                .add(snakePosition.last - rowSize + totalNumberOfSquares);
          } else {
            snakePosition.add(snakePosition.last - rowSize);
          }
        }
        break;
      case snake_Direction.DOWN:
        {
          //add a head
          if (snakePosition.last + rowSize > totalNumberOfSquares) {
            snakePosition
                .add(snakePosition.last + rowSize - totalNumberOfSquares);
          } else {
            snakePosition.add(snakePosition.last + rowSize);
          }
        }
        break;
      default:
    }
    //snake eating the food
    if (snakePosition.last == foodPosition) {
      eatFood();
    } else {
      //remove tail
      snakePosition.removeAt(0);
    }
  }

  //game over
  bool gameOver() {
    // the game is over when the snake runs into itself
    //this occurs when there is a duplicate position in the snake position list

    // this list is the body of the snake(no head)
    List<int> bodySnake = snakePosition.sublist(0, snakePosition.length - 1);

    if (bodySnake.contains(snakePosition.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    //get the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != snake_Direction.UP) {
            currentDirection = snake_Direction.DOWN;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
              currentDirection != snake_Direction.DOWN) {
            currentDirection = snake_Direction.UP;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != snake_Direction.RIGHT) {
            currentDirection = snake_Direction.LEFT;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != snake_Direction.LEFT) {
            currentDirection = snake_Direction.RIGHT;
          }
        },
        child: SizedBox(
          width: screenWidth > 428 ? 428 : screenWidth,
          child: Column(
            children: [
              //High Scores
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //user current score
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (gameHasStarted) Text('Current Score'),
                          if (gameHasStarted)
                            Text(
                              currentScore.toString(),
                              style: TextStyle(fontSize: 36),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    //highscore, top 5 or 10
                    Expanded(
                      child: gameHasStarted
                          ? Container()
                          : FutureBuilder(
                              future: letsGetDocIds,
                              builder: (context, snapshot) {
                                return Column(
                                  children: [
                                    Text('Highscores',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                        height:
                                            10), // Adjust the spacing as needed
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: highscore_DocIds.length,
                                        itemBuilder: ((context, index) {
                                          return HighscoreTile(
                                            documentId: highscore_DocIds[index],
                                            position: index + 1,
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    )
                  ],
                ),
              ),

              //Game Grid

              Expanded(
                flex: 3,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currentDirection != snake_Direction.UP) {
                      currentDirection = snake_Direction.DOWN;
                    } else if (details.delta.dy < 0 &&
                        currentDirection != snake_Direction.DOWN) {
                      currentDirection = snake_Direction.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currentDirection != snake_Direction.LEFT) {
                      currentDirection = snake_Direction.RIGHT;
                    } else if (details.delta.dx < 0 &&
                        currentDirection != snake_Direction.RIGHT) {
                      currentDirection = snake_Direction.LEFT;
                    }
                  },
                  child: GridView.builder(
                      itemCount: totalNumberOfSquares,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowSize),
                      itemBuilder: (context, index) {
                        if (snakePosition.contains(index)) {
                          return const SnakePixel();
                        } else if (foodPosition == index) {
                          return const FoodPixel();
                        } else {
                          return const BlankPixel();
                        }
                      }),
                ),
              ),

              // Play Button
              Expanded(
                child: Container(
                  child: Center(
                    child: MaterialButton(
                      child: Text('PLAY'),
                      color: gameHasStarted ? Colors.grey : Colors.pink,
                      onPressed: gameHasStarted ? () {} : startGame,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
