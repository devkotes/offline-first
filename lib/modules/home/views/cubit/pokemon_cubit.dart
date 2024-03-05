import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../models/pokemon.dart';
import '../../repositories/local_pokemon_repository.dart';
import '../../repositories/remote_pokemon_repository.dart';

part 'pokemon_state.dart';

class PokemonCubit extends Cubit<PokemonState> {
  final RemotePokemonRepository remotePokemonRepository;
  final LocalPokemonRepository localPokemonRepository;
  final Connectivity connectivity;
  PokemonCubit(this.remotePokemonRepository, this.localPokemonRepository,
      this.connectivity)
      : super(PokemonInitial());

  Future<void> getPokemonList() async {
    final connectivityStatus = await connectivity.checkConnectivity();
    if (connectivityStatus == ConnectivityResult.none) {
      getLocalPokemonList();
    } else {
      getRemotePokemonList();
    }
  }

  Future<void> getRemotePokemonList() async {
    try {
      emit(PokemonLoading());
      debugPrint('Pokemon Online');
      final result = await remotePokemonRepository.getAllPokemons();
      emit(RemotePokemonLoaded(pokemonList: result));
    } catch (error) {
      emit(PokemonError());
    }
  }

  Future<void> getLocalPokemonList() async {
    try {
      emit(PokemonLoading());
      debugPrint('Pokemon Offline');
      //delay to fake http request fetch time
      await Future.delayed(const Duration(milliseconds: 500));
      final result = await localPokemonRepository.getAllPokemons();
      emit(LocalPokemonLoaded(pokemonList: result));
    } catch (error) {
      emit(PokemonError());
    }
  }

  Future<void> updateLocalPokemonDatabase(List<Pokemon> pokemonList) async {
    try {
      await localPokemonRepository.updateLocalPokemonDatatable(pokemonList);
      emit(LocalPokemonSync());
    } catch (error) {
      emit(PokemonError());
    }
  }
}
