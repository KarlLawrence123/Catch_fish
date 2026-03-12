import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/detection_data.dart';

class DiseaseInfoScreen extends StatelessWidget {
  const DiseaseInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Disease Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catfish Diseases',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Learn about common catfish diseases and how to prevent them',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: [
                _buildDiseaseCard(
                  context,
                  'Columnaris',
                  'Bacterial infection causing cotton-like growth',
                  Icons.coronavirus,
                  AppTheme.dangerColor,
                  ColumnarisInfo(),
                ),
                _buildDiseaseCard(
                  context,
                  'Aeromonas',
                  'Hemorrhagic septicemia and ulcers',
                  Icons.water_drop,
                  AppTheme.warningColor,
                  AeromonasInfo(),
                ),
                _buildDiseaseCard(
                  context,
                  'White Spot',
                  'Protozoan parasite with white spots',
                  Icons.grain,
                  AppTheme.secondaryColor,
                  WhiteSpotInfo(),
                ),
                _buildDiseaseCard(
                  context,
                  'Fungal Infection',
                  'Cotton wool-like fungal growth',
                  Icons.cloud,
                  AppTheme.primaryColor,
                  FungalInfectionInfo(),
                ),
                _buildDiseaseCard(
                  context,
                  'Fin Rot',
                  'Progressive deterioration of fins',
                  Icons.waves,
                  AppTheme.suspiciousColor,
                  FinRotInfo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    Widget detailScreen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseDetailScreen(
              title: title,
              color: color,
              icon: icon,
              detailScreen: detailScreen,
            ),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shadowColor: color.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Learn More',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiseaseDetailScreen extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Widget detailScreen;

  const DiseaseDetailScreen({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.detailScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: detailScreen,
    );
  }
}

class ColumnarisInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Symptoms', [
            'White or grayish cotton-like growth on skin, fins, and gills',
            'Lesions and ulcers on the body',
            'Frayed fins and fin rot',
            'Lethargy and loss of appetite',
            'Rapid breathing due to gill damage',
          ], AppTheme.dangerColor),
          _buildSection('Causes', [
            'Bacterial infection by Flavobacterium columnare',
            'Poor water quality and high stress levels',
            'Overcrowding in ponds',
            'Injuries or wounds on fish',
            'Sudden temperature changes',
          ], AppTheme.dangerColor),
          _buildSection('Treatment', [
            'Antibiotics: Oxytetracycline or Kanamycin',
            'Potassium permanganate baths (1-2 mg/L)',
            'Salt treatment (1-3% NaCl solution)',
            'Improve water quality immediately',
            'Isolate infected fish to prevent spread',
          ], AppTheme.dangerColor),
          _buildSection('Prevention', [
            'Maintain optimal water quality parameters',
            'Avoid overcrowding in ponds',
            'Quarantine new fish before introduction',
            'Provide proper nutrition to boost immunity',
            'Regular health monitoring of fish',
          ], AppTheme.dangerColor),
        ],
      ),
    );
  }
}

class AeromonasInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Symptoms', [
            'Hemorrhagic septicemia (blood poisoning)',
            'Red spots and ulcers on the body',
            'Abdominal swelling (dropsy)',
            'Exophthalmia (pop-eye)',
            'Internal organ damage',
          ], AppTheme.warningColor),
          _buildSection('Causes', [
            'Bacterial infection by Aeromonas hydrophila',
            'Contaminated water or feed',
            'Stress from poor environmental conditions',
            'Parasitic infections that create wounds',
            'High organic load in water',
          ], AppTheme.warningColor),
          _buildSection('Treatment', [
            'Antibiotics: Enrofloxacin or Florfenicol',
            'Sulfonamides for systemic infections',
            'Supportive care with clean water',
            'Vitamin C supplementation',
            'Remove affected fish from main pond',
          ], AppTheme.warningColor),
          _buildSection('Prevention', [
            'Regular water testing and quality management',
            'Proper pond sanitation and disinfection',
            'Balanced feeding practices',
            'Stress reduction techniques',
            'Vaccination where available',
          ], AppTheme.warningColor),
        ],
      ),
    );
  }
}

class WhiteSpotInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Symptoms', [
            'White salt-like spots on skin and fins',
            'Flashing or rubbing against objects',
            'Clamped fins and lethargy',
            'Rapid breathing',
            'Loss of appetite',
          ], AppTheme.secondaryColor),
          _buildSection('Causes', [
            'Protozoan parasite Ichthyophthirius multifiliis',
            'Introduction of infected fish',
            'Poor water quality',
            'Stress and weakened immunity',
            'Temperature fluctuations',
          ], AppTheme.secondaryColor),
          _buildSection('Treatment', [
            'Raise water temperature to 30°C (86°F)',
            'Formalin or malachite green treatment',
            'Salt treatment (0.3-0.5% NaCl)',
            'Copper sulfate medications',
            'Increase aeration during treatment',
          ], AppTheme.secondaryColor),
          _buildSection('Prevention', [
            'Quarantine new fish for 2-4 weeks',
            'Maintain stable water temperature',
            'Regular water changes',
            'Avoid overcrowding',
            'Monitor fish behavior daily',
          ], AppTheme.secondaryColor),
        ],
      ),
    );
  }
}

class FungalInfectionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Symptoms', [
            'Cotton wool-like growth on skin',
            'White or gray fuzzy patches',
            'Secondary bacterial infections',
            'Lethargy and poor appetite',
            'Scratching against surfaces',
          ], AppTheme.primaryColor),
          _buildSection('Causes', [
            'Fungal pathogens (Saprolegnia, Achlya)',
            'Poor water quality',
            'Injuries or wounds on fish',
            'Stress and weakened immunity',
            'Dead organic matter in pond',
          ], AppTheme.primaryColor),
          _buildSection('Treatment', [
            'Salt baths (1-3% NaCl)',
            'Malachite green or formalin treatment',
            'Potassium permanganate dips',
            'Remove dead organic material',
            'Improve water circulation',
          ], AppTheme.primaryColor),
          _buildSection('Prevention', [
            'Maintain excellent water quality',
            'Remove dead fish and organic debris',
            'Handle fish carefully to avoid injuries',
            'Proper filtration and aeration',
            'Regular pond cleaning',
          ], AppTheme.primaryColor),
        ],
      ),
    );
  }
}

class FinRotInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Symptoms', [
            'Progressive deterioration of fins',
            'Fins appear ragged and frayed',
            'White edges on affected fins',
            'Inflammation at fin base',
            'Secondary bacterial infections',
          ], AppTheme.suspiciousColor),
          _buildSection('Causes', [
            'Bacterial infection (Pseudomonas, Aeromonas)',
            'Poor water quality',
            'Stress and overcrowding',
            'Injuries from aggressive fish',
            'Nutritional deficiencies',
          ], AppTheme.suspiciousColor),
          _buildSection('Treatment', [
            'Antibiotics: Tetracycline or Kanamycin',
            'Salt treatment (0.5-1% NaCl)',
            'Improve water quality immediately',
            'Remove aggressive tank mates',
            'Vitamin supplements in feed',
          ], AppTheme.suspiciousColor),
          _buildSection('Prevention', [
            'Maintain optimal water parameters',
            'Provide adequate space for fish',
            'Balanced and nutritious diet',
            'Regular water changes',
            'Monitor fish behavior closely',
          ], AppTheme.suspiciousColor),
        ],
      ),
    );
  }
}

// Updated _buildSection to accept color as a parameter and remove const
Widget _buildSection(String title, List<String> items, Color themeColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: themeColor,
        ),
      ),
      const SizedBox(height: 8),
      ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: themeColor)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          )),
      const SizedBox(height: 16),
    ],
  );
}