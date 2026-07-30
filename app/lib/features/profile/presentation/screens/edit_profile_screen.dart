import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  File? _avatarFile;
  String? _avatarBase64;
  bool _saving = false;

  // Realtime calculated values
  double _bmi = 0.0;
  double _bmr = 0.0;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.profile.weight?.toStringAsFixed(1) ?? '60.0');
    _heightController = TextEditingController(text: widget.profile.height?.toStringAsFixed(1) ?? '165.0');
    _recalculateMetrics();

    _weightController.addListener(_recalculateMetrics);
    _heightController.addListener(_recalculateMetrics);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _recalculateMetrics() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final height = double.tryParse(_heightController.text) ?? 0.0;
    final age = widget.profile.age ?? 25;
    final isMale = widget.profile.gender == 'Pria';

    if (weight > 0 && height > 0) {
      // BMI
      final heightM = height / 100.0;
      _bmi = weight / (heightM * heightM);

      // BMR (Mifflin-St Jeor)
      _bmr = (10 * weight) + (6.25 * height) - (5 * age);
      if (isMale) {
        _bmr += 5;
      } else {
        _bmr -= 161;
      }
    } else {
      _bmi = 0.0;
      _bmr = 0.0;
    }
    setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _avatarFile = file;
          _avatarBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final weight = double.parse(_weightController.text);
    final height = double.parse(_heightController.text);

    try {
      // 1. Sync to Remote Server
      final response = await http.post(
        Uri.parse(ApiEndpoints.updateProfile),
        headers: {
          'Authorization': 'Bearer ${widget.profile.authToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'weight': weight,
          'height': height,
          if (_avatarBase64 != null) 'avatar_base64': _avatarBase64,
        }),
      );

      if (response.statusCode == 200) {
        // 2. Save locally to SQLite Drift DB
        final db = ref.read(databaseProvider);
        await db.updateUserProfile(
          widget.profile.id,
          UserProfilesCompanion(
            weight: Value(weight),
            height: Value(height),
          ),
        );

        // 3. Reload active profile state
        await ref.read(authProvider.notifier).checkActiveSession();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: AppColors.primary),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Gagal sinkronisasi data ke server.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Avatar URL from server
    final serverAvatarUrl = 'https://yodi.my.id/veg/uploads/avatars/user${widget.profile.id}.jpg?t=${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: AppColors.surfaceVariant,
                          backgroundImage: _avatarFile != null
                              ? FileImage(_avatarFile!)
                              : NetworkImage(serverAvatarUrl) as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => SafeArea(
                                  child: Wrap(
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.photo_library),
                                        title: const Text('Galeri Foto'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.gallery);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Kamera'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.camera);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Metrics Input Fields
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Berat Badan (kg)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Harus diisi';
                            if (double.tryParse(val) == null) return 'Angka tidak valid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Tinggi Badan (cm)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Harus diisi';
                            if (double.tryParse(val) == null) return 'Angka tidak valid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Dynamic Calculated BMR & BMI Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hasil Estimasi Real-Time', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('BMI', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _bmi.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 40, color: AppColors.divider),
                              Column(
                                children: [
                                  const Text('BMR (Basal Metabolic)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_bmr.toInt()} kkal',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
