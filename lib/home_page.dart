import 'dart:async';
import 'dart:math';

import 'package:first_app/blank_pixel.dart';
import 'package:first_app/food_pixel.dart';
import 'package:first_app/snake_pixel.dart';
import 'package:flutter/material.dart';

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

  //user score
  int currentScore = 0;

  //snake position
  List<int> snakePosition = [0, 1, 2];

  //snake direction is initially to the right
  var currentDirection = snake_Direction.RIGHT;

  //food position
  int foodPosition = 55;

  //Start Game
  void startGame() {
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
            builder: (context) {
              return AlertDialog(
                title: Text('GAME OVER'),
                content:
                    Text('Your Current Score is: ' + currentScore.toString()),
              );
            },
          );
        }
      });
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //High Scores

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //user current score
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Current Score:'),
                    Text(
                      currentScore.toString(),
                      style: TextStyle(fontSize: 36),
                    ),
                  ],
                ),
                //highscore, top 5 or 10
                Text('Highscore')
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
                  color: Colors.pink,
                  onPressed: startGame,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
