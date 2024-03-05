import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/pokemon.dart';
import '../repositories/local_pokemon_repository.dart';
import '../repositories/remote_pokemon_repository.dart';
import 'cubit/pokemon_cubit.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final PokemonCubit pokemonCubit;
  late final _remotePokemonRepository;
  late final _localPokemonRepository;
  late final _connectivity;

  @override
  void initState() {
    _remotePokemonRepository = RemotePokemonRepository();
    _localPokemonRepository = LocalPokemonRepository();
    _connectivity = Connectivity();

    pokemonCubit = PokemonCubit(
      _remotePokemonRepository,
      _localPokemonRepository,
      _connectivity,
    );

    pokemonCubit.getPokemonList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline First App Example'),
      ),
      body: BlocConsumer<PokemonCubit, PokemonState>(
        bloc: pokemonCubit,
        listener: (context, state) {
          if (state is RemotePokemonLoaded) {
            _localPokemonRepository.updateLocalPokemonDatatable(
              state.pokemonList,
            );
          }
        },
        builder: (context, state) {
          if (state is PokemonLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RemotePokemonLoaded) {
            return HomePageBody(pokemonList: state.pokemonList);
          }

          if (state is LocalPokemonLoaded) {
            return HomePageBody(pokemonList: state.pokemonList);
          }

          if (state is PokemonError) {
            return const Center(
              child: Text('Error.'),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class HomePageBody extends StatelessWidget {
  final List<Pokemon> pokemonList;
  const HomePageBody({
    super.key,
    required this.pokemonList,
  });

  @override
  Widget build(BuildContext context) {
    if (pokemonList.isEmpty) {
      return const Center(child: Text('No pokemons.'));
    }
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        children: [
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: pokemonList.length,
            itemBuilder: (context, index) {
              final pokemon = pokemonList[index];
              return ListTile(
                title: Text(pokemon.name),
              );
            },
          )
        ],
      ),
    );
  }
}
