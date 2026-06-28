import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/species/species_bloc.dart';
import '../bloc/species/species_event.dart';
import '../bloc/species/species_state.dart';
import 'species/species_list_screen.dart'; // Pour utiliser SpeciesTile

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Clear search when going back
        context.read<SpeciesBloc>().add(const SearchSpecies(''));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              context.read<SpeciesBloc>().add(const SearchSpecies(''));
              Navigator.pop(context);
            },
          ),
          title: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) => context.read<SpeciesBloc>().add(SearchSpecies(value)),
            decoration: InputDecoration(
              hintText: 'Rechercher parmi les 11000 espèces...',
              border: InputBorder.none,
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
            ),
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                _searchController.clear();
                context.read<SpeciesBloc>().add(const SearchSpecies(''));
              },
            ),
          ],
        ),
        body: BlocBuilder<SpeciesBloc, SpeciesState>(
          builder: (context, state) {
            if (state is SpeciesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SpeciesLoaded) {
              final list = state.filteredSpecies;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune espèce correspondante.',
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final species = list[index];
                  return SpeciesTile(species: species);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
