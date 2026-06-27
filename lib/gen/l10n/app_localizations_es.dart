// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get account => 'Cuenta';

  @override
  String get addAnotherPlayer => 'Anadir otro jugador';

  @override
  String get appleSignInFailed => 'Fallo el inicio de sesion con Apple.';

  @override
  String get appTitle => 'VTeam Cards';

  @override
  String get back => 'Atras';

  @override
  String get cancel => 'Cancelar';

  @override
  String cardCountTooltip(int count) {
    return '$count\\ncartas';
  }

  @override
  String get cardGamesTitle => 'Juegos de cartas';

  @override
  String get cardsTitle => 'Cards';

  @override
  String columnsByRows(int columns, int rows) {
    return '$columns x $rows';
  }

  @override
  String get confirm => 'Confirmar';

  @override
  String confirmDeleteRound(int round) {
    return 'Seguro que quieres eliminar la ronda $round?';
  }

  @override
  String get confirmNewGame =>
      'Seguro que quieres empezar una nueva partida? Se perderan todas las puntuaciones.';

  @override
  String get corrections => 'Correcciones';

  @override
  String get correctionsAll => 'Todo';

  @override
  String get correctionsApprove => 'Aprobar';

  @override
  String get correctionsApproved => 'Aprobada';

  @override
  String get correctionsBackendRequired =>
      'La revision de correcciones requiere conexion con el backend.';

  @override
  String get correctionsCorrectedValue => 'Valor corregido';

  @override
  String get correctionsDecisionSaved => 'Decision de revision guardada';

  @override
  String get correctionsDetectedValue => 'Valor detectado';

  @override
  String get correctionsNoApproved =>
      'No se encontraron correcciones aprobadas.';

  @override
  String get correctionsNoData => 'No se encontraron correcciones.';

  @override
  String get correctionsNoPending =>
      'No hay correcciones pendientes de revision.';

  @override
  String get correctionsNoRejected =>
      'No se encontraron correcciones rechazadas.';

  @override
  String get correctionsPending => 'Pendientes';

  @override
  String get correctionsReject => 'Rechazar';

  @override
  String get correctionsRejected => 'Rechazada';

  @override
  String get correctionsReviewerOnly =>
      'Solo los usuarios del grupo reviewer pueden acceder a esta pantalla.';

  @override
  String get correctionsReviewStatus => 'Estado de la revision';

  @override
  String get correctionsSubmittedAt => 'Enviado';

  @override
  String get correctionsSubmittedBy => 'Enviado por';

  @override
  String get correctionsTitle => 'Correcciones de entrenamiento';

  @override
  String get correctionsWebOnly =>
      'La revision de correcciones esta disponible actualmente en la web.';

  @override
  String get createNewTable => 'Crear mesa';

  @override
  String get createTableNameHint =>
      'Elige un nombre de mesa sencillo. Si ya existe, te ayudaremos a unirte.';

  @override
  String get deleteLastRow => 'Eliminar ultima fila';

  @override
  String get discardOrSwap => 'Descartar →\\no\\n↓ cambiar';

  @override
  String get done => 'Hecho';

  @override
  String get drawCardHere => 'Roba\\nuna carta\\naqui\\n→';

  @override
  String get editInitials => 'Editar iniciales';

  @override
  String get email => 'Correo electronico';

  @override
  String get enterTableName => 'Introduce el nombre de la nueva mesa.';

  @override
  String errorLoadingScores(String error) {
    return 'Error al cargar las puntuaciones: $error';
  }

  @override
  String get exit => 'Salir';

  @override
  String finalRoundYouHaveToBeat(String turnText, String attacker) {
    return 'Ronda final. $turnText. Tienes que vencer a $attacker';
  }

  @override
  String get flipOpenOneHiddenCard =>
      '↓ Da la vuelta a una de tus cartas ocultas ↓';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get gameOver => 'Fin de la partida';

  @override
  String get gameOverTitle => 'FIN DE LA PARTIDA';

  @override
  String get gameRules => 'Reglas del juego';

  @override
  String get gamesWon => 'Partidas ganadas';

  @override
  String get golf9Cards => '9 Cartas';

  @override
  String get golf9CardsFull => 'Golf 9 Cartas';

  @override
  String get golfScoreKeeper => 'Marcador de Golf 9 Cartas';

  @override
  String get googleSignInFailed => 'Fallo el inicio de sesion con Google.';

  @override
  String get identityChangeableLater => 'Puedes cambiar esto mas tarde';

  @override
  String get identityChooseActionTitle => 'Que quieres hacer?';

  @override
  String get identityFirstSubtitle => 'Los demas veran este nombre en la mesa.';

  @override
  String get identityFirstTitle => 'Quien eres?';

  @override
  String get identityHostHint => 'Eres el anfitrion.';

  @override
  String get identityJoinHint => 'Tienes un enlace o el nombre de la mesa.';

  @override
  String get identitySignInWithApple => 'Iniciar sesion con Apple';

  @override
  String get identitySignInWithGoogle => 'Iniciar sesion con Google';

  @override
  String get instructionsCustom => 'Reglas personalizadas';

  @override
  String get instructionsFrenchCards9 =>
      '- Intenta conseguir la puntuacion mas baja.\n- Elige una carta del mazo o del descarte.\n- Intercambia la carta elegida con una carta de tu cuadrícula de 3x3, o descartala y da la vuelta a una de tus cartas boca abajo.\n- Tres cartas del mismo valor en una fila o columna valen cero.\n- El primer jugador que revele sus nueve cartas desafia al resto y afirma tener la puntuacion mas baja.\n- Si otra persona consigue una puntuacion igual o menor, el retador duplica sus puntos.\n- Los jugadores quedan eliminados al superar 100 puntos.\n\n\nMas informacion [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsMiniPut =>
      '- Intenta conseguir la puntuacion mas baja.\n- Elige una carta del mazo o del descarte.\n- Intercambia la carta elegida con una carta de tu cuadrícula de 2x2, o descartala y da la vuelta a una de tus cartas boca abajo.\n- Tres cartas del mismo valor en una fila o columna valen cero.\n- El primer jugador que revele sus cartas desafia al resto y afirma tener la puntuacion mas baja.\n- Si otra persona consigue una puntuacion igual o menor, el retador duplica sus puntos.\n- Los jugadores quedan eliminados al superar 100 puntos.\n\n\nMas informacion [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsSkyjo =>
      '- Intenta conseguir la puntuacion mas baja.\n- Elige una carta del mazo o del descarte.\n- Intercambia la carta elegida con una carta de tu cuadrícula de 4x3, o descartala y da la vuelta a una de tus cartas boca abajo.\n- Cuando 3 cartas del mismo valor se alinean en una columna, se mueven a la pila de descarte.\n- El primer jugador que revele todas sus cartas desafia al resto y afirma tener la puntuacion mas baja.\n\n\nMas informacion [Skyjo](https://www.geekyhobbies.com/how-to-play-skyjo-card-game-rules-and-instructions/)';

  @override
  String itsPlayersTurn(String player) {
    return 'Es el turno de $player';
  }

  @override
  String itsYourTurn(String player) {
    return 'Es tu turno $player';
  }

  @override
  String get join => 'Unirse';

  @override
  String get joinExistingGame => 'Unirse a una partida';

  @override
  String get joinGame => 'Unirse a la partida';

  @override
  String get joinGameTitle => 'Unirse a la partida';

  @override
  String get joinTable => 'Unirse a la mesa';

  @override
  String get joinThisTable => 'Unirse a esta mesa';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => '🇬🇧\nEN';

  @override
  String get languageFrench => '🇫🇷\nFR';

  @override
  String get languagePortuguesePortugal => '🇵🇹\nPT';

  @override
  String get languageSpanish => '🇪🇸\nES';

  @override
  String get last => 'ULTIMO';

  @override
  String get miniPut => 'MiniPut';

  @override
  String get miniPutFull => 'MiniPut 4 Cartas';

  @override
  String get newGame => 'Nueva partida';

  @override
  String get next => 'Siguiente';

  @override
  String get noCardsAvailableToDraw => 'No hay cartas disponibles para robar.';

  @override
  String get noMatchingTables => 'No hay mesas coincidentes';

  @override
  String get noOne => 'Nadie';

  @override
  String get noTablesAvailable => 'No hay mesas disponibles';

  @override
  String noTablesFoundMatching(String searchText) {
    return 'No se encontraron mesas que coincidan con \"$searchText\"';
  }

  @override
  String get notAllowed => 'No permitido!';

  @override
  String get notYourTurn => 'No es tu turno!';

  @override
  String get orHereLeft => '\\no\\naqui\\n←';

  @override
  String get otherTools => 'Otras herramientas';

  @override
  String get pickTableOrCreateHint =>
      'Elige una mesa existente o crea una nueva.';

  @override
  String get playAgain => 'Jugar de nuevo';

  @override
  String get playerName => 'Iniciales del jugador';

  @override
  String get players => 'Jugadores';

  @override
  String playerWonTimesAtTable(String player, int count, String table) {
    return '$player gano $count veces en la mesa $table';
  }

  @override
  String get pleaseEnterYourName => 'Introduce tu nombre arriba ⬆';

  @override
  String readyToPlayPlayersAtTable(int count) {
    return 'Todo listo para jugar. $count jugadores en la mesa.';
  }

  @override
  String get remove => 'Eliminar';

  @override
  String get removePlayer => 'Eliminar jugador';

  @override
  String removePlayerConfirmation(String playerName) {
    return 'Seguro que quieres eliminar a \"$playerName\"?';
  }

  @override
  String get removeThisPlayer => 'Eliminar a este jugador';

  @override
  String rounds(int count) {
    return '$count Rondas';
  }

  @override
  String get scanCameraError => 'Error de camara: ';

  @override
  String get scanCard => 'Contar cartas';

  @override
  String get scanCardTitle => 'Contar cartas';

  @override
  String get scanCorrectCardValueTitle => 'Corregir valor de la carta';

  @override
  String get scanCorrectionRequiresSignIn =>
      'Inicia sesion con una cuenta para corregir los valores de las cartas.';

  @override
  String get scanCorrectionSaved =>
      'Correccion guardada para el reentrenamiento del modelo';

  @override
  String get scanFailedDecode => 'No se pudo decodificar la imagen capturada.';

  @override
  String get scanMacosPhotoHint =>
      'En macOS, elige una foto de una carta de tu biblioteca para escanearla.';

  @override
  String get scanModelError => 'No se pudo cargar el modelo: ';

  @override
  String get scanModelLoading =>
      'El modelo aun se esta cargando. Espera un momento.';

  @override
  String get scanNoCameraFound =>
      'No se encontro ninguna camara en este dispositivo.';

  @override
  String get scanRankAce => 'As (1)';

  @override
  String get scanRankAceTitle => 'As (1)';

  @override
  String get scanRankJack => 'S (11)';

  @override
  String get scanRankJackTitle => 'Sota (11)';

  @override
  String get scanRankJoker => 'Joker (-2)';

  @override
  String get scanRankKing => 'R (0)';

  @override
  String get scanRankKingTitle => 'Rey (0)';

  @override
  String get scanRankQueen => 'D (12)';

  @override
  String get scanRankQueenTitle => 'Reina (12)';

  @override
  String get scanTapToCorrect =>
      'Toca una burbuja de valor de carta para corregirla';

  @override
  String get scanWebPhotoHint =>
      'Elige una foto de una carta de tu dispositivo para escanearla.';

  @override
  String get scoreKeeper => 'Marcador';

  @override
  String get selectAStatus => 'Selecciona un estado';

  @override
  String get selectTableToJoin => 'Selecciona una mesa';

  @override
  String get signIn => 'Iniciar sesion';

  @override
  String get signOut => 'Cerrar sesion';

  @override
  String get signOutFailed => 'Fallo al cerrar sesion.';

  @override
  String get skyjo => 'Skyjo';

  @override
  String get startGame => 'Iniciar partida';

  @override
  String get startGameWizardSubtitle =>
      'Elige el juego para esta mesa. Te ayudaremos a nombrarla despues.';

  @override
  String get starting => 'Iniciando';

  @override
  String get startTable => 'Crear mesa';

  @override
  String get statusBrb => 'Ahora vuelvo';

  @override
  String get statusFeelingGood => 'Todo bien!';

  @override
  String get statusOhNo => 'Ay no!';

  @override
  String get statusThinking => 'Pensando...';

  @override
  String get statusVoila => 'Listo!';

  @override
  String get swapThisWith => 'cambia esto →\\n\\npor ↓';

  @override
  String get table => 'Mesa';

  @override
  String tableLabel(String table) {
    return 'Mesa: $table';
  }

  @override
  String get thisGame => 'Esta partida';

  @override
  String get thisTableAlreadyHasPlayers =>
      'Esta mesa ya existe. Unete a esta mesa o introduce otro nombre.';

  @override
  String get useSearchBox =>
      'Usa la busqueda para encontrar una mesa rapidamente';

  @override
  String get waitForYourTurnSmiley => 'Espera tu turno :)';

  @override
  String get waitingForMorePlayers =>
      'Esperando a que se unan mas jugadores...';

  @override
  String get waitingForPlayers => 'Esperando a que se unan jugadores';

  @override
  String get waitYourTurn => 'Espera tu turno!';

  @override
  String get whatTypeOfGame => 'Que tipo de juego?';

  @override
  String get whoAreYou => 'Quien eres?\\nSelecciona arriba ⬆ o unete abajo ⬇';

  @override
  String get wizardStepOneOfTwo => 'Paso 1 de 2';

  @override
  String get wizardStepTwoOfTwo => 'Paso 2 de 2';

  @override
  String get youAreDone => 'Has terminado.';

  @override
  String get youIndicator => 'TU>';
}
