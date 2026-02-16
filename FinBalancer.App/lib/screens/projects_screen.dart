import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/project.dart';
import '../providers/data_provider.dart';
import '../providers/subscription_provider.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _api = ApiService();
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _error;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _showForm = false;
  Project? _editing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _projects = await _api.getProjects();
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _error = null);
    try {
      if (_editing != null) {
        await _api.updateProject(Project(
          id: _editing!.id,
          name: name,
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          color: _editing!.color,
          createdAt: _editing!.createdAt,
        ));
      } else {
        await _api.addProject(Project(id: '', name: name, description: _descController.text.trim().isEmpty ? null : _descController.text.trim()));
      }
      _nameController.clear();
      _descController.clear();
      setState(() { _showForm = false; _editing = null; });
      await _load();
      if (mounted) context.read<DataProvider>().loadAll();
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _edit(Project p) {
    _editing = p;
    _nameController.text = p.name;
    _descController.text = p.description ?? '';
    setState(() => _showForm = true);
  }

  Future<void> _delete(Project p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text('Remove "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: AppTheme.expense(context)))),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _api.deleteProject(p.id);
        await _load();
        if (mounted) context.read<DataProvider>().loadAll();
      } catch (e) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text('Projects', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, sub, _) => _buildBody(isPremium: sub.isPremium),
      ),
    );
  }

  Widget _buildBody({required bool isPremium}) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isPremium) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.amber.shade700),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Projects is a Premium feature. Upgrade to add or edit.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.amber.shade900))),
                    TextButton(onPressed: () => Navigator.pushNamed(context, '/premium-features'), child: const Text('Upgrade')),
                  ],
                ),
              ),
            ],
            if (_showForm) _buildForm(isPremium: isPremium),
            if (!_showForm) _buildAddButton(isPremium: isPremium),
            const SizedBox(height: 24),
            if (_projects.isEmpty && !_showForm) _buildEmpty()
            else ..._projects.map((p) => _buildProjectCard(p, isPremium: isPremium)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm({required bool isPremium}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_editing != null ? 'Edit Project' : 'New Project', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Vacation 2025'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() { _showForm = false; _editing = null; _nameController.clear(); _descController.clear(); }),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: isPremium ? _save : null, child: const Text('Save'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({required bool isPremium}) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isPremium ? () => setState(() => _showForm = true) : null,
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
        style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.accent(context))),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No projects yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Add a project to group transactions', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project p, {required bool isPremium}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.folder, color: AppTheme.accent(context), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (p.description != null && p.description!.isNotEmpty)
                  Text(p.description!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: isPremium ? () => _edit(p) : null),
          IconButton(icon: Icon(Icons.delete, color: AppTheme.expense(context)), onPressed: isPremium ? () => _delete(p) : null),
        ],
      ),
    );
  }
}
