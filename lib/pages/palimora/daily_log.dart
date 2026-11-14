import 'package:aletheia/data/palimora_database.dart';
import 'package:aletheia/utilities/uniform_appbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class DailyLog extends StatefulWidget {
  const DailyLog({super.key});

  @override
  State<DailyLog> createState() => _DailyLogState();
}

enum CheckInStep {
  mood,
  sleep,
  pillars1,
  pillars2,
  pillars3,
  pillars4,
  pillars5,
  pillars6,
  complete,
}

class _DailyLogState extends State<DailyLog> {
  final _myBox = Hive.box('MyBox');
  PalimoraDatabase db = PalimoraDatabase();

  CheckInStep _currentStep = CheckInStep.mood;

  String? _selectedMood;

  Map<String, double> pillarRatings = {};

  final TextEditingController _sleepController = TextEditingController();
  double hoursSlept = -1;
  double qualityOfSleep = 0;

  @override
  void initState() {
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
          _currentStep = CheckInStep.pillars1;
          break;
        case CheckInStep.pillars1:
          _currentStep = CheckInStep.pillars2;
        case CheckInStep.pillars2:
          _currentStep = CheckInStep.pillars3;
        case CheckInStep.pillars3:
          _currentStep = CheckInStep.pillars4;
        case CheckInStep.pillars4:
          _currentStep = CheckInStep.pillars5;
        case CheckInStep.pillars5:
          _currentStep = CheckInStep.pillars6;
        case CheckInStep.pillars6:
          _currentStep = CheckInStep.complete;
          saveMoodAndPillarRatings();
          break;
        case CheckInStep.complete:
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
        onPress: () => Navigator.pop(context, false),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
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
              ],
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
          },
        );
      }).toList(),
    );
  }

  // 3. Updated _buildSleepSelector implementation:
  Widget _buildHoursOfSleepSelector() {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: _sleepController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // 1. Blocks non-numeric characters and enforces max ONE decimal point
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
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
            // 2. If empty or invalid, fallback to -1 instead of 0.0
            hoursSlept = double.tryParse(value) ?? -1;
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

  // Updated to accept an optional onRated callback for automatic transitions
  Widget _buildPillarRatingSelector(String key, {VoidCallback? onRated}) {
    final List<double> ratings = [1, 2, 3, 4, 5];

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: ratings.map((rating) {
        final isSelected = pillarRatings[key] == rating;
        return ChoiceChip(
          label: Text(rating.toInt().toString()),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                pillarRatings[key] = rating;
                if (onRated != null) {
                  onRated();
                }
              } else {
                pillarRatings.remove(key);
              }
            });
          },
        );
      }).toList(),
    );
  }

  // Builder helper for individual pillar steps
  Widget _buildSinglePillarStep(int index) {
    final pillar = _pillars[index];
    final String key = pillar['key']!;
    final String prompt = pillar['prompt']!;

    return SingleChildScrollView(
      key: ValueKey(
        'pillar_step_$index',
      ), // Unique key triggers AnimatedSwitcher
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 40),
          _buildPillarRatingSelector(
            key,
            onRated: () {
              // 150ms delay gives user visual confirmation before fading out
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) nextStep();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _getStepWidget() {
    return switch (_currentStep) {
      CheckInStep.mood => SingleChildScrollView(
        key: const ValueKey('mood_step'), // Unique key,
        child: Column(
          children: [
            const Text(
              'How was your day today?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            _buildMoodSelector(),

            const SizedBox(height: 150),

            ElevatedButton(
              onPressed: () {
                // 1. Check if all pillars have a non-null rating selected

                if (_selectedMood != null) {
                  // All rated -> advance step
                  nextStep();
                } else {
                  // 2. Clear old snackbars & show a small error
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a mood before continuing.'),
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

          const SizedBox(height: 150),
          ElevatedButton(
            onPressed: () {
              if (hoursSlept >= 0 && hoursSlept <= 14 && qualityOfSleep > 0) {
                nextStep();
              } else if (hoursSlept > 14) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Did you sleep or were you fucking dead?'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                // 2. Clear old snackbars & show a small error
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please complete sleep logging before continuing.',
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

      CheckInStep.pillars1 => _buildSinglePillarStep(0),
      CheckInStep.pillars2 => _buildSinglePillarStep(1),
      CheckInStep.pillars3 => _buildSinglePillarStep(2),
      CheckInStep.pillars4 => _buildSinglePillarStep(3),
      CheckInStep.pillars5 => _buildSinglePillarStep(4),
      CheckInStep.pillars6 => _buildSinglePillarStep(5),

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
            onPressed: () => Navigator.pop(context, true), // ✅ Exits the flow
            child: const Text('Done'),
          ),
        ],
      ),
    };
  }
}
