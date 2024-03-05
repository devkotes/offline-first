import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../helper/db_helper.dart';
import '../models/pokemon.dart';

class RemotePokemonRepository {
  final dio = Dio();
  var databaseFuture = DatabaseHelper.db.database;
  static const POKEMON_TABLE_NAME = 'pokemon';
  static const POKEMON_API_URL =
      'https://pokeapi.co/api/v2/pokemon?limit=100&offset=200';

  Future<List<Pokemon>> getAllPokemons() async {
    late final List<Pokemon> pokemonList;
    final Database database = await databaseFuture;
    try {
      Response response = await dio.get(POKEMON_API_URL);

      if (response.statusCode == 200) {
        final pokemons = (response.data['results'] as List);
        pokemonList =
            pokemons.map((pokemon) => Pokemon.fromJson(pokemon)).toList();
      }
    } on DioException catch (_) {
      final pokemonMap = await database.query(POKEMON_TABLE_NAME);
      pokemonList =
          pokemonMap.map((pokemon) => Pokemon.fromJson(pokemon)).toList();
    }
    return pokemonList;
  }
}
