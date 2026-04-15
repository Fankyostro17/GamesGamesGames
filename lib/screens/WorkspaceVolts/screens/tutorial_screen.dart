import 'package:flutter/material.dart';
import '../../../icons/CustomIconsTutorial/CustomIconsTutorial.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TUTORIAL',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'PressStart2P',
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSection(
            title: 'CONTROLLI',
            leadingIcon: Image.asset(
              'assets/images/controller.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            items: [
            _ControlItem(
              icon: CustomIconsTutorial.right_fat,
              title: 'Muoviti',
              desc: 'Frecce / Pulsanti touch',
            ),
            _ControlItem(
              icon: CustomIconsTutorial.up_fat,
              title: 'Salta',
              desc: 'Spazio / Pulsante SALTA',
            ),
            _ControlItem(
              icon: CustomIconsTutorial.exit_to_app,
              title: 'Uscita',
              desc: 'Raccogli almeno il 50% degli oggetti per sbloccarla',
            ),
          ], 
          titleColor: Colors.orange),

          const SizedBox(height: 24),

          _buildSection(
            title: 'OGGETTI SICUREZZA',
            leadingIcon: Image.asset(
              'assets/images/shield.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            items: [
            _SecurityItem(
              imagePath: 'assets/images/glove.png',
              title: 'Guanti Isolanti',
              points: '+10 punti',
              desc: 'Protezione dalle scariche elettriche',
            ),
            _SecurityItem(
              imagePath: 'assets/images/helmet.png',
              title: 'Casco Sicurezza',
              points: '+15 punti',
              desc: 'Protegge la testa dai pericoli',
            ),
            _SecurityItem(
              imagePath: 'assets/images/firetruck.png',
              title: 'Idrante',
              points: '+20 punti',
              desc: 'Spegne incendi e crea zone sicure',
            ),
            _SecurityItem(
              imagePath: 'assets/images/extinguisher.png',
              title: 'Estintore',
              points: '+25 punti',
              desc: 'Fondamentale per la sicurezza antincendio',
            ),
          ],
          titleColor: Colors.green),

          const SizedBox(height: 24),

          _buildSection(
            title: 'PERICOLI', 
            leadingIcon: Image.asset(
              'assets/images/skull.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            items: [
            _HazardItem(
              imagePath: 'assets/images/lightning.png',
              title: 'Scarica Elettrica',
              desc: 'Evita le zone elettrificate!',
            ),
            _HazardItem(
              imagePath: 'assets/images/exposed_cable.png',
              title: 'Cavo Scoperto',
              desc: 'I cavi esposti sono mortali!',
            ),
            _HazardItem(
              imagePath: 'assets/images/electrical_panel.png',
              title: 'Quadro Elettrico',
              desc: 'Non avvicinarti senza protezione!',
            ),
            _HazardItem(
              imagePath: 'assets/images/fire.png',
              title: 'Incendio',
              desc: 'Usa 🧯 Estintore o 🚒 Idrante per spegnerlo!',
            ),
          ],
          titleColor: Colors.red),

          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF12233A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E5FF), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.flash_on,
                    size: 32,
                    color: Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Raccogli gli oggetti di sicurezza, evita i pericoli elettrici e gli incendi, poi raggiungi l\'uscita!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '100 livelli con difficoltà crescente',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title, 
    required List<Widget> items,
    Color? titleColor,
    Widget? leadingIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
        children: [
          if (leadingIcon != null) ...[
            leadingIcon,
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              color: titleColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ...items,
      ],
    );
  }

  Widget _ControlItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF12233A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[800]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.cyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _SecurityItem({
    required String imagePath,
    required String title,
    required String points,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF12233A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[700]!, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          Text(points, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _HazardItem({
    required String imagePath,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF12233A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[700]!, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}