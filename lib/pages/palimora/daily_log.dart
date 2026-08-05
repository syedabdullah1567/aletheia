import 'package:aletheia/data/palimora_database.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class DailyLog extends StatefulWidget {
  const DailyLog({super.key});

  @override
  State<DailyLog> createState() => _DailyLogState();
}

enum CheckInStep { mood, sleep, pillars, complete }

class _DailyLogState extends State<DailyLog> {
  final _myBox = Hive.box('MyBox');
  PalimoraDatabase db = PalimoraDatabase();

  CheckInStep _currentStep = CheckInStep.mood;

  String? _selectedMood;

  Map<String, double> pillarRatings = {};

  final TextEditingController _sleepController = TextEditingController();
  double hoursSlept = 0.0;

  double qualityOfSleep = 0;

  @override
  void initState() {
    if (_myBox.get('HASLOGGED') == null) {
      db.createInitialData(0);
      db.updateDataBase(0);
    } else {
      db.loadData(0);
    }

    if (_myBox.get('MOODS') == null) {
      db.createInitialData(1);
      db.updateDataBase(1);
    } else {
      db.loadData(1);
    }

    if (_myBox.get('SLEEP') == null) {
      db.createInitialData(2);
      db.updateDataBase(2);
    } else {
      db.loadData(2);
    }

    if (_myBox.get('PILLARRATINGS') == null) {
      db.createInitialData(3);
      db.updateDataBase(3);
    } else {
      db.loadData(3);
    }
    super.initState();
  }

  final List<Map<String, String>> _pillars = const [
    {
      'key': 'mental',
      'prompt':
          'How clear, grounded, and emotionally stable did your mind feel today?',
    },
    {
      'key': 'physical',
      'prompt': 'How well did you nourish, rest, and honor your physical body?',
    },
    {
      'key': 'family',
      'prompt':
          'Did you feel genuinely connected and present with your family and loved ones?',
    },
    {
      'key': 'financial',
      'prompt':
          'How intentional and in control did you feel regarding your finances today?',
    },
    {
      'key': 'career',
      'prompt':
          'Did your work and focus today align with your long-term vision?',
    },
    {
      'key': 'spiritual',
      'prompt':
          'How connected did you feel to your inner peace and higher purpose?',
    },
  ];

  void nextStep() {
    setState(() {
      switch (_currentStep) {
        case CheckInStep.mood:
          _currentStep = CheckInStep.sleep;
          break;
        case CheckInStep.sleep:
          _currentStep = CheckInStep.pillars;
          break;
        case CheckInStep.pillars:
          _currentStep = CheckInStep.complete;
          saveMoodAndPillarRatings();
          break;
        case CheckInStep.complete:
          saveMoodAndPillarRatings();
          break;
      }
    });
  }

  void saveMoodAndPillarRatings() {
    String timestampKey = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    db.moods[timestampKey] = _selectedMood ?? 'Neutral';
    db.sleep[timestampKey] = {
      'hoursSlept': hoursSlept,
      'qualityOfSleep': qualityOfSleep,
    };
    db.pillarRatings[timestampKey] = pillarRatings;

    // Save entries to Hive
    db.updateDataBase(1); // Saves 'MOODS'
    db.updateDataBase(2); // Saves 'SLEEP'
    db.updateDataBase(3); // Saves 'PILLARRATINGS'
    db.updateDataBase(0); // Saves current cycle key to 'LAST_LOGGED_CYCLE'
  }

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    //final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: UniformAppbar(
        leadIcon: Icon(Icons.arrow_back_rounded),
        titleText: '',
        onPress: () => Navigator.pop(context),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(50, 50, 50, 50),
          child: Center(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _getStepWidget(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    final List<String> moods = ['Happy', 'Neutral', 'Sad'];

    return Wrap(
      spacing: 12.0,
      children: moods.map((mood) {
        final isSelected = _selectedMood == mood;
        return ChoiceChip(
          label: Text(mood),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              _selectedMood = selected ? mood : null;
            });

            if (selected) {
              Future.delayed(const Duration(milliseconds: 10), nextStep);
            }
          },
        );
      }).toList(),
    );
  }

  // 3. Updated _buildSleepSelector implementation:
  Widget _buildHoursOfSleepSelector() {
    return SizedBox(
      width: 200, // Keeps the input centered and neat
      child: TextField(
        controller: _sleepController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: '8.0',
          suffixText: 'hrs',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            // Parse string input to double safely
            hoursSlept = double.tryParse(value) ?? 0.0;
          });
        },
      ),
    );
  }

  Widget _buildQualityOfSleepSelector() {
    final List<double> qualities = [1, 2, 3, 4, 5];

    return Wrap(
      spacing: 12.0,
      children: qualities.map((quality) {
        final isSelected = qualityOfSleep == quality;
        return ChoiceChip(
          label: Text(quality.toInt().toString()),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                qualityOfSleep = quality;
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPillarRatingSelector(String index) {
    final List<double> ratings = [1, 2, 3, 4, 5];

    return Wrap(
      spacing: 12.0,
      children: ratings.map((rating) {
        final isSelected = pillarRatings[index] == rating;
        return ChoiceChip(
          label: Text(rating.toInt().toString()),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                pillarRatings[index] = rating;
              } else {
                pillarRatings.remove(index);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _getStepWidget() {
    return switch (_currentStep) {
      CheckInStep.mood => Column(
        key: const ValueKey('mood_step'), // Unique key
        children: [
          const Text(
            'How was your day today?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          _buildMoodSelector(),
        ],
      ),

      CheckInStep.sleep => Column(
        key: const ValueKey('sleep_step'), // Unique key
        children: [
          const Text(
            'How many hours did you sleep today?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          _buildHoursOfSleepSelector(),
          const SizedBox(height: 100),
          const Text(
            'How would you rate your overall sleep quality?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          _buildQualityOfSleepSelector(),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => nextStep(), // ✅ Exits the flow
            child: const Text('Next'),
          ),
        ],
      ),

      CheckInStep.pillars => SingleChildScrollView(
        key: const ValueKey('pillars_step'),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // Collection-for loop + Spread operator (...)
            for (final pillar in _pillars) ...[
              Text(
                pillar['prompt']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              _buildPillarRatingSelector(pillar['key']!),
              const SizedBox(height: 35),
            ],

            // Manual button to proceed since there are multiple inputs
            ElevatedButton(
              onPressed: () {
                // 1. Check if all pillars have a non-null rating selected
                final bool allRated = _pillars.every(
                  (pillar) => pillarRatings[pillar['key']] != null,
                );

                if (allRated) {
                  // All rated -> advance step
                  nextStep();
                } else {
                  // 2. Clear old snackbars & show a small error
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select a rating for all pillars before continuing.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),

      CheckInStep.complete => Column(
        key: const ValueKey('complete_step'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'All set for today!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context), // ✅ Exits the flow
            child: const Text('Done'),
          ),
        ],
      ),
    };
  }
}
