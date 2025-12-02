import 'package:flutter/material.dart';

class KakuroCell {
  final bool isClue;
  final int? horizontalClue;
  final int? verticalClue;
  int? value;

  KakuroCell({
    this.isClue = false,
    this.horizontalClue,
    this.verticalClue,
    this.value,
  });
}

List<List<KakuroCell>> generatePuzzle() {
  return [
    [KakuroCell(), KakuroCell(), KakuroCell(), KakuroCell(), KakuroCell()],
    [
      KakuroCell(),
      KakuroCell(isClue: true, horizontalClue: 16, verticalClue: 10),
      KakuroCell(),
      KakuroCell(),
      KakuroCell(),
    ],
    [
      KakuroCell(),
      KakuroCell(),
      KakuroCell(),
      KakuroCell(isClue: true, horizontalClue: 9),
      KakuroCell(),
    ],
    [
      KakuroCell(isClue: true, verticalClue: 16),
      KakuroCell(),
      KakuroCell(),
      KakuroCell(),
      KakuroCell(),
    ],
    [
      KakuroCell(isClue: true, verticalClue: 10),
      KakuroCell(),
      KakuroCell(),
      KakuroCell(),
      KakuroCell(),
    ],
  ];
}

class KakuroGame extends StatefulWidget {
  final String title;
  final int size;

  const KakuroGame({super.key, required this.title, this.size = 5});

  @override
  State<KakuroGame> createState() => _KakuroGameState();
}

class _KakuroGameState extends State<KakuroGame> {
  late List<List<KakuroCell>> grid;
  int selectedRow = -1;
  int selectedCol = -1;

  @override
  void initState() {
    super.initState();
    grid = generatePuzzle();
  }

  void _onCellTap(int row, int col) {
    if (!grid[row][col].isClue) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    }
  }

  void _onNumberPressed(int number) {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        grid[selectedRow][selectedCol].value = grid[selectedRow][selectedCol].value == number ? null : number;
      });
    }
  }

  void _clearCell() {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        grid[selectedRow][selectedCol].value = null;
      });
    }
  }

  bool _isPuzzleSolved() {
    for (var row in grid) {
      for (var cell in row) {
        if (!cell.isClue && cell.value == null) return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.size,
                  childAspectRatio: 1.0,
                ),
                itemCount: widget.size * widget.size,
                itemBuilder: (context, index) {
                  int row = index ~/ widget.size;
                  int col = index % widget.size;
                  KakuroCell cell = grid[row][col];
                  bool isSelected = row == selectedRow && col == selectedCol;

                  return GestureDetector(
                    onTap: () => _onCellTap(row, col),
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: isSelected ? Colors.yellow.withOpacity(0.3) : Colors.white,
                      ),
                      child: cell.isClue
                          ? _buildClueCell(cell)
                          : _buildInputCell(cell),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildKeypad(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearCell,
        child: const Icon(Icons.clear),
      ),
    );
  }

  Widget _buildClueCell(KakuroCell cell) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cell.verticalClue != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                '${cell.verticalClue}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          if (cell.horizontalClue != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 4, top: 2),
                child: Text(
                  '${cell.horizontalClue}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputCell(KakuroCell cell) {
    return Center(
      child: cell.value != null
          ? Text(
              '${cell.value}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildKeypad() {
    return SizedBox(
      height: 150,
      child: GridView.count(
        crossAxisCount: 5,
        children: List.generate(9, (i) {
          int num = i + 1;
          return ElevatedButton(
            onPressed: () => _onNumberPressed(num),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            child: Text('$num', style: const TextStyle(fontSize: 18)),
          );
        }),
      ),
    );
  }
}