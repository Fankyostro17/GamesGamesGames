import 'package:flutter/material.dart';

// --- Modelli ---
enum ItemType { gloves, helmet, extinguisher, idrante }
enum ObstacleType { electricShock, exposedCable, electricalPanel, fire }

class Item {
  final ItemType type;
  final Offset pos;
  final int points;

  Item({required this.type, required this.pos, required this.points});
}

class Obstacle {
  final ObstacleType type;
  final Offset pos;

  Obstacle({required this.type, required this.pos});
}

class Exit {
  final Offset pos;

  Exit({required this.pos});
}

// --- Livello ---
class Level {
  final List<Item> items;
  final List<Obstacle> obstacles;
  final Exit exit;
  final Set<Offset> platforms;
  final Offset playerStartPos;

  Level({
    required this.items,
    required this.obstacles,
    required this.exit,
    required this.platforms,
    required this.playerStartPos,
  });

  int get maxPossibleScore {
    return items.fold(0, (sum, item) => sum + item.points);
  }

  // ✅ Costruttore da matrice (per facilitare l'aggiunta di nuovi livelli)
  factory Level.fromMatrix(List<String> matrix) {
    final items = <Item>[];
    final obstacles = <Obstacle>[];
    Exit? exit;
    final platforms = <Offset>{};
    Offset? playerStartPos;

    for (int row = 0; row < matrix.length; row++) {
      final cells = matrix[row].split(' ');
      for (int col = 0; col < cells.length; col++) {
        final char = cells[col];
        final pos = Offset(col.toDouble(), row.toDouble());

        switch (char) {
          case 'b':
            platforms.add(pos);
            break;
          case 'f':
            items.add(Item(type: ItemType.gloves, pos: pos, points: 10));
            break;
          case 'e':
            items.add(Item(type: ItemType.extinguisher, pos: pos, points: 25));
            break;
          case 'p':
            exit = Exit(pos: pos);
            break;
          case 'c':
            items.add(Item(type: ItemType.helmet, pos: pos, points: 15));
            break;
          case 's':
            obstacles.add(Obstacle(type: ObstacleType.exposedCable, pos: pos));
            break;
          case 'o':
            playerStartPos = pos;
            break;
          case 'w':
            obstacles.add(Obstacle(type: ObstacleType.fire, pos: pos));
            break;
          case 'h':
            items.add(Item(type: ItemType.idrante, pos: pos, points: 20));
            break;
          case 'z':
            obstacles.add(Obstacle(type: ObstacleType.electricShock, pos: pos));
            break;
          case 'x':
            obstacles.add(Obstacle(type: ObstacleType.electricalPanel, pos: pos));
            break;
          default:
            break; // 'a' → ignorato
        }
      }
    }

    if (exit == null) throw ArgumentError('Livello deve contenere una porta (p)');
    if (playerStartPos == null) throw ArgumentError('Livello deve contenere una posizione giocatore (o)');

    return Level(
      items: items,
      obstacles: obstacles,
      exit: exit,
      platforms: platforms,
      playerStartPos: playerStartPos,
    );
  }
}

// --- Lista dei livelli ---
final List<Level> allLevels = [
  // Livello 1 — come da tua matrice
  Level.fromMatrix([
    'b a a a a a a a a a a b',
    'b a a a a a a a a a a b',
    'b a a a a a a a a a a b',
    'b w e p c a a a a a a b',
    'b b b b b b a a a a a b',
    'b a a a a a a a a a a b',
    'b a b b b b b a a a a b',
    'b a a a a c a a a a a b',
    'b a a b b b b b a a a b',
    'b a a a a a a a a a a b',
    'b a a a a a b b b a a b',
    'b a a a a a a a a a a b',
    'b b b b b a a a a a a b',
    'b a a a a a a a a a s b',
    'b o a a a a a a a a a b',
    'b b b b b b b b b b b b',
  ]),

  // Livello 2 - Incendio
  Level.fromMatrix([
    'b b b b b b b b b b b b',
    'b o a a a a a a a a a b',
    'b b b a a a a a a a a b',
    'b a a a a w a a a a a b',
    'b a a b b b b b a a a b',
    'b a a a a a a a a a a b',
    'b a w w w a a a a a a b',
    'b b b b b a a a a a a b',
    'b a a a a a a a a a a b',
    'b a a a a a a w w b b b',
    'b a a a a a a a a a a b',  
    'b a a a a a a a a a a b',
    'b a a h a a w w w a a b',
    'b b b b b b b b b a a b',
    'b a a a a a a a a a p b',
    'b b b b b b b b b b b b',
  ]),

  Level.fromMatrix([
    'b b b b b b b b b b b b',
    'b o a a a a a a a a a b',
    'b b b z a a x a a a a b',
    'b a a a a a a a a a a b',
    'b a a a a a a a a a a b',
    'b a a b b b b b a a a b',
    'b a a a s a a a a a a b',
    'b a f a z e a a a a a b',
    'b b b b b a c a a a a b',
    'b a a a a a a a a a a b',
    'b a a a a a a a a a a b',
    'b a a a a a a a a a a b',
    'b a a a a a a a a a s b',
    'b b b b b b b b b a a b',
    'b p a a a a a a w a a b',
    'b b b b b b b b b b b b',
  ]),
];