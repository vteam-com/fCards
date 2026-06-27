// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get account => 'Conta';

  @override
  String get addAnotherPlayer => 'Adicionar outro jogador';

  @override
  String get appleSignInFailed => 'Falha ao iniciar sessao com Apple.';

  @override
  String get appTitle => 'VTeam Cards';

  @override
  String get back => 'Voltar';

  @override
  String get cancel => 'Cancelar';

  @override
  String cardCountTooltip(int count) {
    return '$count\\ncartas';
  }

  @override
  String get cardGamesTitle => 'Jogos de cartas';

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
    return 'Tem a certeza de que quer apagar a ronda $round?';
  }

  @override
  String get confirmNewGame =>
      'Tem a certeza de que quer comecar um novo jogo? Todas as pontuacoes serao perdidas.';

  @override
  String get corrections => 'Correcoes';

  @override
  String get correctionsAll => 'Todas';

  @override
  String get correctionsApprove => 'Aprovar';

  @override
  String get correctionsApproved => 'Aprovada';

  @override
  String get correctionsBackendRequired =>
      'A revisao de correcoes requer ligacao ao backend.';

  @override
  String get correctionsCorrectedValue => 'Valor corrigido';

  @override
  String get correctionsDecisionSaved => 'Decisao de revisao guardada';

  @override
  String get correctionsDetectedValue => 'Valor detetado';

  @override
  String get correctionsNoApproved =>
      'Nao foram encontradas correcoes aprovadas.';

  @override
  String get correctionsNoData => 'Nao foram encontradas correcoes.';

  @override
  String get correctionsNoPending => 'Nao ha correcoes pendentes para rever.';

  @override
  String get correctionsNoRejected =>
      'Nao foram encontradas correcoes rejeitadas.';

  @override
  String get correctionsPending => 'Pendentes';

  @override
  String get correctionsReject => 'Rejeitar';

  @override
  String get correctionsRejected => 'Rejeitada';

  @override
  String get correctionsReviewerOnly =>
      'Apenas os utilizadores do grupo reviewer podem aceder a este ecra.';

  @override
  String get correctionsReviewStatus => 'Estado da revisao';

  @override
  String get correctionsSubmittedAt => 'Enviado em';

  @override
  String get correctionsSubmittedBy => 'Enviado por';

  @override
  String get correctionsTitle => 'Correcoes de treino';

  @override
  String get correctionsWebOnly =>
      'A revisao de correcoes esta atualmente disponivel na web.';

  @override
  String get createNewTable => 'Criar mesa';

  @override
  String get createTableNameHint =>
      'Escolha um nome simples para a mesa. Se ja existir, ajudamos a entrar nela.';

  @override
  String get deleteLastRow => 'Apagar ultima linha';

  @override
  String get discardOrSwap => 'Descartar →\\nou\\n↓ trocar';

  @override
  String get done => 'Concluido';

  @override
  String get drawCardHere => 'Tire\\numa carta\\naqui\\n→';

  @override
  String get editInitials => 'Editar iniciais';

  @override
  String get email => 'E-mail';

  @override
  String get enterTableName => 'Introduza o nome da nova mesa.';

  @override
  String errorLoadingScores(String error) {
    return 'Erro ao carregar pontuacoes: $error';
  }

  @override
  String get exit => 'Sair';

  @override
  String finalRoundYouHaveToBeat(String turnText, String attacker) {
    return 'Ronda final. $turnText. Tem de vencer $attacker';
  }

  @override
  String get flipOpenOneHiddenCard => '↓ Vire uma das suas cartas escondidas ↓';

  @override
  String get fullName => 'Nome completo';

  @override
  String get gameOver => 'Fim do jogo';

  @override
  String get gameOverTitle => 'FIM DO JOGO';

  @override
  String get gameRules => 'Regras do jogo';

  @override
  String get gamesWon => 'Jogos ganhos';

  @override
  String get golf9Cards => '9 Cartas';

  @override
  String get golf9CardsFull => 'Golf 9 Cartas';

  @override
  String get golfScoreKeeper => 'Marcador de Golf 9 Cartas';

  @override
  String get googleSignInFailed => 'Falha ao iniciar sessao com Google.';

  @override
  String get identityChangeableLater => 'Podes alterar isto mais tarde';

  @override
  String get identityChooseActionTitle => 'O que queres fazer?';

  @override
  String get identityFirstSubtitle => 'Os outros veem este nome na mesa.';

  @override
  String get identityFirstTitle => 'Quem es?';

  @override
  String get identityHostHint => 'Es o anfitriao.';

  @override
  String get identityJoinHint => 'Tens uma ligacao ou o nome da mesa.';

  @override
  String get identitySignInWithApple => 'Iniciar sessao com Apple';

  @override
  String get identitySignInWithGoogle => 'Iniciar sessao com Google';

  @override
  String get instructionsCustom => 'Regras personalizadas';

  @override
  String get instructionsFrenchCards9 =>
      '- Tenta obter a pontuacao mais baixa.\n- Escolhe uma carta do baralho ou do descarte.\n- Troca a carta escolhida por uma carta da tua grelha 3x3, ou descarta-a e vira uma das tuas cartas viradas para baixo.\n- Tres cartas do mesmo valor numa linha ou coluna valem zero.\n- O primeiro jogador a revelar as suas nove cartas desafia os outros e afirma ter a pontuacao mais baixa.\n- Se outra pessoa obtiver uma pontuacao igual ou inferior, o desafiante duplica os seus pontos.\n- Os jogadores sao eliminados ao ultrapassar 100 pontos.\n\n\nSaber mais [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsMiniPut =>
      '- Tenta obter a pontuacao mais baixa.\n- Escolhe uma carta do baralho ou do descarte.\n- Troca a carta escolhida por uma carta da tua grelha 2x2, ou descarta-a e vira uma das tuas cartas viradas para baixo.\n- Tres cartas do mesmo valor numa linha ou coluna valem zero.\n- O primeiro jogador a revelar as suas cartas desafia os outros e afirma ter a pontuacao mais baixa.\n- Se outra pessoa obtiver uma pontuacao igual ou inferior, o desafiante duplica os seus pontos.\n- Os jogadores sao eliminados ao ultrapassar 100 pontos.\n\n\nSaber mais [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsSkyjo =>
      '- Tenta obter a pontuacao mais baixa.\n- Escolhe uma carta do baralho ou do descarte.\n- Troca a carta escolhida por uma carta da tua grelha 4x3, ou descarta-a e vira uma das tuas cartas viradas para baixo.\n- Quando 3 cartas do mesmo valor se alinham numa coluna, sao movidas para a pilha de descarte.\n- O primeiro jogador a revelar todas as suas cartas desafia os outros e afirma ter a pontuacao mais baixa.\n\n\nSaber mais [Skyjo](https://www.geekyhobbies.com/how-to-play-skyjo-card-game-rules-and-instructions/)';

  @override
  String itsPlayersTurn(String player) {
    return 'E a vez de $player';
  }

  @override
  String itsYourTurn(String player) {
    return 'E a tua vez $player';
  }

  @override
  String get join => 'Entrar';

  @override
  String get joinExistingGame => 'Entrar num jogo';

  @override
  String get joinGame => 'Entrar no jogo';

  @override
  String get joinGameTitle => 'Entrar no jogo';

  @override
  String get joinTable => 'Entrar na mesa';

  @override
  String get joinThisTable => 'Entrar nesta mesa';

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
  String get newGame => 'Novo jogo';

  @override
  String get next => 'Seguinte';

  @override
  String get noCardsAvailableToDraw => 'Nao ha cartas disponiveis para tirar.';

  @override
  String get noMatchingTables => 'Sem mesas correspondentes';

  @override
  String get noOne => 'Ninguem';

  @override
  String get noTablesAvailable => 'Nao ha mesas disponiveis';

  @override
  String noTablesFoundMatching(String searchText) {
    return 'Nao foram encontradas mesas que correspondam a \"$searchText\"';
  }

  @override
  String get notAllowed => 'Nao permitido!';

  @override
  String get notYourTurn => 'Nao e a tua vez!';

  @override
  String get orHereLeft => '\\nou\\naqui\\n←';

  @override
  String get otherTools => 'Outras ferramentas';

  @override
  String get pickTableOrCreateHint =>
      'Escolhe uma mesa existente ou cria uma nova.';

  @override
  String get playAgain => 'Jogar novamente';

  @override
  String get playerName => 'Iniciais do jogador';

  @override
  String get players => 'Jogadores';

  @override
  String playerWonTimesAtTable(String player, int count, String table) {
    return '$player ganhou $count vezes na mesa $table';
  }

  @override
  String get pleaseEnterYourName => 'Introduz o teu nome acima ⬆';

  @override
  String readyToPlayPlayersAtTable(int count) {
    return 'Pronto para jogar. $count jogadores na mesa.';
  }

  @override
  String get remove => 'Remover';

  @override
  String get removePlayer => 'Remover jogador';

  @override
  String removePlayerConfirmation(String playerName) {
    return 'Tem a certeza de que quer remover \"$playerName\"?';
  }

  @override
  String get removeThisPlayer => 'Remover este jogador';

  @override
  String rounds(int count) {
    return '$count Rondas';
  }

  @override
  String get scanCameraError => 'Erro da camara: ';

  @override
  String get scanCard => 'Contar cartas';

  @override
  String get scanCardTitle => 'Contar cartas';

  @override
  String get scanCorrectCardValueTitle => 'Corrigir valor da carta';

  @override
  String get scanCorrectionRequiresSignIn =>
      'Inicia sessao com uma conta para corrigir os valores das cartas.';

  @override
  String get scanCorrectionSaved =>
      'Correcao guardada para novo treino do modelo';

  @override
  String get scanFailedDecode => 'Falha ao descodificar a imagem capturada.';

  @override
  String get scanMacosPhotoHint =>
      'No macOS, escolhe uma fotografia de uma carta da tua biblioteca para a analisar.';

  @override
  String get scanModelError => 'Nao foi possivel carregar o modelo: ';

  @override
  String get scanModelLoading => 'O modelo ainda esta a carregar. Aguarda.';

  @override
  String get scanNoCameraFound =>
      'Nao foi encontrada nenhuma camara neste dispositivo.';

  @override
  String get scanRankAce => 'As (1)';

  @override
  String get scanRankAceTitle => 'As (1)';

  @override
  String get scanRankJack => 'V (11)';

  @override
  String get scanRankJackTitle => 'Valete (11)';

  @override
  String get scanRankJoker => 'Joker (-2)';

  @override
  String get scanRankKing => 'R (0)';

  @override
  String get scanRankKingTitle => 'Rei (0)';

  @override
  String get scanRankQueen => 'D (12)';

  @override
  String get scanRankQueenTitle => 'Dama (12)';

  @override
  String get scanTapToCorrect =>
      'Toca numa bolha de valor da carta para a corrigir';

  @override
  String get scanWebPhotoHint =>
      'Escolhe uma fotografia de uma carta do teu dispositivo para a analisar.';

  @override
  String get scoreKeeper => 'Marcador';

  @override
  String get selectAStatus => 'Seleciona um estado';

  @override
  String get selectTableToJoin => 'Seleciona uma mesa';

  @override
  String get signIn => 'Iniciar sessao';

  @override
  String get signOut => 'Terminar sessao';

  @override
  String get signOutFailed => 'Falha ao terminar sessao.';

  @override
  String get skyjo => 'Skyjo';

  @override
  String get startGame => 'Iniciar jogo';

  @override
  String get startGameWizardSubtitle =>
      'Escolhe o jogo para esta mesa. Ajudamos a dar-lhe um nome a seguir.';

  @override
  String get starting => 'A iniciar';

  @override
  String get startTable => 'Criar mesa';

  @override
  String get statusBrb => 'Ja volto';

  @override
  String get statusFeelingGood => 'A sentir-me bem!';

  @override
  String get statusOhNo => 'Oh nao!';

  @override
  String get statusThinking => 'A pensar...';

  @override
  String get statusVoila => 'Ja esta!';

  @override
  String get swapThisWith => 'troca isto →\\n\\npor ↓';

  @override
  String get table => 'Mesa';

  @override
  String tableLabel(String table) {
    return 'Mesa: $table';
  }

  @override
  String get thisGame => 'Este jogo';

  @override
  String get thisTableAlreadyHasPlayers =>
      'Esta mesa ja existe. Entra nesta mesa ou introduz outro nome.';

  @override
  String get useSearchBox =>
      'Usa a pesquisa para encontrar uma mesa rapidamente';

  @override
  String get waitForYourTurnSmiley => 'Espera pela tua vez :)';

  @override
  String get waitingForMorePlayers => 'A espera de mais jogadores...';

  @override
  String get waitingForPlayers => 'A espera de jogadores';

  @override
  String get waitYourTurn => 'Espera pela tua vez!';

  @override
  String get whatTypeOfGame => 'Que tipo de jogo?';

  @override
  String get whoAreYou => 'Quem es?\\nSeleciona acima ⬆ ou entra abaixo ⬇';

  @override
  String get wizardStepOneOfTwo => 'Passo 1 de 2';

  @override
  String get wizardStepTwoOfTwo => 'Passo 2 de 2';

  @override
  String get youAreDone => 'Terminaste.';

  @override
  String get youIndicator => 'TU>';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get account => 'Conta';

  @override
  String get addAnotherPlayer => 'Adicionar outro jogador';

  @override
  String get appleSignInFailed => 'Falha ao iniciar sessao com Apple.';

  @override
  String get appTitle => 'VTeam Cards';

  @override
  String get back => 'Voltar';

  @override
  String get cancel => 'Cancelar';

  @override
  String cardCountTooltip(int count) {
    return '$count\\ncartas';
  }

  @override
  String get cardGamesTitle => 'Jogos de cartas';

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
    return 'Tem a certeza de que quer apagar a ronda $round?';
  }

  @override
  String get confirmNewGame =>
      'Tem a certeza de que quer comecar um novo jogo? Todas as pontuacoes serao perdidas.';

  @override
  String get corrections => 'Correcoes';

  @override
  String get correctionsAll => 'Todas';

  @override
  String get correctionsApprove => 'Aprovar';

  @override
  String get correctionsApproved => 'Aprovada';

  @override
  String get correctionsBackendRequired =>
      'A revisao de correcoes requer ligacao ao backend.';

  @override
  String get correctionsCorrectedValue => 'Valor corrigido';

  @override
  String get correctionsDecisionSaved => 'Decisao de revisao guardada';

  @override
  String get correctionsDetectedValue => 'Valor detetado';

  @override
  String get correctionsNoApproved =>
      'Nao foram encontradas correcoes aprovadas.';

  @override
  String get correctionsNoData => 'Nao foram encontradas correcoes.';

  @override
  String get correctionsNoPending => 'Nao ha correcoes pendentes para rever.';

  @override
  String get correctionsNoRejected =>
      'Nao foram encontradas correcoes rejeitadas.';

  @override
  String get correctionsPending => 'Pendentes';

  @override
  String get correctionsReject => 'Rejeitar';

  @override
  String get correctionsRejected => 'Rejeitada';

  @override
  String get correctionsReviewerOnly =>
      'Apenas os utilizadores do grupo reviewer podem aceder a este ecra.';

  @override
  String get correctionsReviewStatus => 'Estado da revisao';

  @override
  String get correctionsSubmittedAt => 'Enviado em';

  @override
  String get correctionsSubmittedBy => 'Enviado por';

  @override
  String get correctionsTitle => 'Correcoes de treino';

  @override
  String get correctionsWebOnly =>
      'A revisao de correcoes esta atualmente disponivel na web.';

  @override
  String get createNewTable => 'Criar mesa';

  @override
  String get createTableNameHint =>
      'Escolha um nome simples para a mesa. Se ja existir, ajudamos a entrar nela.';

  @override
  String get deleteLastRow => 'Apagar ultima linha';

  @override
  String get discardOrSwap => 'Descartar →\\nou\\n↓ trocar';

  @override
  String get done => 'Concluido';

  @override
  String get drawCardHere => 'Tire\\numa carta\\naqui\\n→';

  @override
  String get editInitials => 'Editar iniciais';

  @override
  String get email => 'E-mail';

  @override
  String get enterTableName => 'Introduza o nome da nova mesa.';

  @override
  String errorLoadingScores(String error) {
    return 'Erro ao carregar pontuacoes: $error';
  }

  @override
  String get exit => 'Sair';

  @override
  String finalRoundYouHaveToBeat(String turnText, String attacker) {
    return 'Ronda final. $turnText. Tem de vencer $attacker';
  }

  @override
  String get flipOpenOneHiddenCard => '↓ Vire uma das suas cartas escondidas ↓';

  @override
  String get fullName => 'Nome completo';

  @override
  String get gameOver => 'Fim do jogo';

  @override
  String get gameOverTitle => 'FIM DO JOGO';

  @override
  String get gameRules => 'Regras do jogo';

  @override
  String get gamesWon => 'Jogos ganhos';

  @override
  String get golf9Cards => '9 Cartas';

  @override
  String get golf9CardsFull => 'Golf 9 Cartas';

  @override
  String get golfScoreKeeper => 'Marcador de Golf 9 Cartas';

  @override
  String get googleSignInFailed => 'Falha ao iniciar sessao com Google.';

  @override
  String get identityChangeableLater => 'Podes alterar isto mais tarde';

  @override
  String get identityChooseActionTitle => 'O que queres fazer?';

  @override
  String get identityFirstSubtitle => 'Os outros veem este nome na mesa.';

  @override
  String get identityFirstTitle => 'Quem es?';

  @override
  String get identityHostHint => 'Es o anfitriao.';

  @override
  String get identityJoinHint => 'Tens uma ligacao ou o nome da mesa.';

  @override
  String get identitySignInWithApple => 'Iniciar sessao com Apple';

  @override
  String get identitySignInWithGoogle => 'Iniciar sessao com Google';

  @override
  String get instructionsCustom => 'Regras personalizadas';

  @override
  String get instructionsFrenchCards9 =>
      '- Tenta obter a pontuacao mais baixa.\n- Escolhe uma carta do baralho ou do descarte.\n- Troca a carta escolhida por uma carta da tua grelha 3x3, ou descarta-a e vira uma das tuas cartas viradas para baixo.\n- Tres cartas do mesmo valor numa linha ou coluna valem zero.\n- O primeiro jogador a revelar as suas nove cartas desafia os outros e afirma ter a pontuacao mais baixa.\n- Se outra pessoa obtiver uma pontuacao igual ou inferior, o desafiante duplica os seus pontos.\n- Os jogadores sao eliminados ao ultrapassar 100 pontos.\n\n\nSaber mais [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsMiniPut =>
      '- Tenta obter a pontuacao mais baixa.\n- Escolhe uma carta do baralho ou do descarte.\n- Troca a carta escolhida por uma carta da tua grelha 2x2, ou descarta-a e vira uma das tuas cartas viradas para baixo.\n- Tres cartas do mesmo valor numa linha ou coluna valem zero.\n- O primeiro jogador a revelar as suas cartas desafia os outros e afirma ter a pontuacao mais baixa.\n- Se outra pessoa obtiver uma pontuacao igual ou inferior, o desafiante duplica os seus pontos.\n- Os jogadores sao eliminados ao ultrapassar 100 pontos.\n\n\nSaber mais [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

  @override
  String get instructionsSkyjo =>
      '- Tenta obter a pontuacao mais baixa.\n- Escolhe uma carta do baralho ou do descarte.\n- Troca a carta escolhida por uma carta da tua grelha 4x3, ou descarta-a e vira uma das tuas cartas viradas para baixo.\n- Quando 3 cartas do mesmo valor se alinham numa coluna, sao movidas para a pilha de descarte.\n- O primeiro jogador a revelar todas as suas cartas desafia os outros e afirma ter a pontuacao mais baixa.\n\n\nSaber mais [Skyjo](https://www.geekyhobbies.com/how-to-play-skyjo-card-game-rules-and-instructions/)';

  @override
  String itsPlayersTurn(String player) {
    return 'E a vez de $player';
  }

  @override
  String itsYourTurn(String player) {
    return 'E a tua vez $player';
  }

  @override
  String get join => 'Entrar';

  @override
  String get joinExistingGame => 'Entrar num jogo';

  @override
  String get joinGame => 'Entrar no jogo';

  @override
  String get joinGameTitle => 'Entrar no jogo';

  @override
  String get joinTable => 'Entrar na mesa';

  @override
  String get joinThisTable => 'Entrar nesta mesa';

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
  String get newGame => 'Novo jogo';

  @override
  String get next => 'Seguinte';

  @override
  String get noCardsAvailableToDraw => 'Nao ha cartas disponiveis para tirar.';

  @override
  String get noMatchingTables => 'Sem mesas correspondentes';

  @override
  String get noOne => 'Ninguem';

  @override
  String get noTablesAvailable => 'Nao ha mesas disponiveis';

  @override
  String noTablesFoundMatching(String searchText) {
    return 'Nao foram encontradas mesas que correspondam a \"$searchText\"';
  }

  @override
  String get notAllowed => 'Nao permitido!';

  @override
  String get notYourTurn => 'Nao e a tua vez!';

  @override
  String get orHereLeft => '\\nou\\naqui\\n←';

  @override
  String get otherTools => 'Outras ferramentas';

  @override
  String get pickTableOrCreateHint =>
      'Escolhe uma mesa existente ou cria uma nova.';

  @override
  String get playAgain => 'Jogar novamente';

  @override
  String get playerName => 'Iniciais do jogador';

  @override
  String get players => 'Jogadores';

  @override
  String playerWonTimesAtTable(String player, int count, String table) {
    return '$player ganhou $count vezes na mesa $table';
  }

  @override
  String get pleaseEnterYourName => 'Introduz o teu nome acima ⬆';

  @override
  String readyToPlayPlayersAtTable(int count) {
    return 'Pronto para jogar. $count jogadores na mesa.';
  }

  @override
  String get remove => 'Remover';

  @override
  String get removePlayer => 'Remover jogador';

  @override
  String removePlayerConfirmation(String playerName) {
    return 'Tem a certeza de que quer remover \"$playerName\"?';
  }

  @override
  String get removeThisPlayer => 'Remover este jogador';

  @override
  String rounds(int count) {
    return '$count Rondas';
  }

  @override
  String get scanCameraError => 'Erro da camara: ';

  @override
  String get scanCard => 'Contar cartas';

  @override
  String get scanCardTitle => 'Contar cartas';

  @override
  String get scanCorrectCardValueTitle => 'Corrigir valor da carta';

  @override
  String get scanCorrectionRequiresSignIn =>
      'Inicia sessao com uma conta para corrigir os valores das cartas.';

  @override
  String get scanCorrectionSaved =>
      'Correcao guardada para novo treino do modelo';

  @override
  String get scanFailedDecode => 'Falha ao descodificar a imagem capturada.';

  @override
  String get scanMacosPhotoHint =>
      'No macOS, escolhe uma fotografia de uma carta da tua biblioteca para a analisar.';

  @override
  String get scanModelError => 'Nao foi possivel carregar o modelo: ';

  @override
  String get scanModelLoading => 'O modelo ainda esta a carregar. Aguarda.';

  @override
  String get scanNoCameraFound =>
      'Nao foi encontrada nenhuma camara neste dispositivo.';

  @override
  String get scanRankAce => 'As (1)';

  @override
  String get scanRankAceTitle => 'As (1)';

  @override
  String get scanRankJack => 'V (11)';

  @override
  String get scanRankJackTitle => 'Valete (11)';

  @override
  String get scanRankJoker => 'Joker (-2)';

  @override
  String get scanRankKing => 'R (0)';

  @override
  String get scanRankKingTitle => 'Rei (0)';

  @override
  String get scanRankQueen => 'D (12)';

  @override
  String get scanRankQueenTitle => 'Dama (12)';

  @override
  String get scanTapToCorrect =>
      'Toca numa bolha de valor da carta para a corrigir';

  @override
  String get scanWebPhotoHint =>
      'Escolhe uma fotografia de uma carta do teu dispositivo para a analisar.';

  @override
  String get scoreKeeper => 'Marcador';

  @override
  String get selectAStatus => 'Seleciona um estado';

  @override
  String get selectTableToJoin => 'Seleciona uma mesa';

  @override
  String get signIn => 'Iniciar sessao';

  @override
  String get signOut => 'Terminar sessao';

  @override
  String get signOutFailed => 'Falha ao terminar sessao.';

  @override
  String get skyjo => 'Skyjo';

  @override
  String get startGame => 'Iniciar jogo';

  @override
  String get startGameWizardSubtitle =>
      'Escolhe o jogo para esta mesa. Ajudamos a dar-lhe um nome a seguir.';

  @override
  String get starting => 'A iniciar';

  @override
  String get startTable => 'Criar mesa';

  @override
  String get statusBrb => 'Ja volto';

  @override
  String get statusFeelingGood => 'A sentir-me bem!';

  @override
  String get statusOhNo => 'Oh nao!';

  @override
  String get statusThinking => 'A pensar...';

  @override
  String get statusVoila => 'Ja esta!';

  @override
  String get swapThisWith => 'troca isto →\\n\\npor ↓';

  @override
  String get table => 'Mesa';

  @override
  String tableLabel(String table) {
    return 'Mesa: $table';
  }

  @override
  String get thisGame => 'Este jogo';

  @override
  String get thisTableAlreadyHasPlayers =>
      'Esta mesa ja existe. Entra nesta mesa ou introduz outro nome.';

  @override
  String get useSearchBox =>
      'Usa a pesquisa para encontrar uma mesa rapidamente';

  @override
  String get waitForYourTurnSmiley => 'Espera pela tua vez :)';

  @override
  String get waitingForMorePlayers => 'A espera de mais jogadores...';

  @override
  String get waitingForPlayers => 'A espera de jogadores';

  @override
  String get waitYourTurn => 'Espera pela tua vez!';

  @override
  String get whatTypeOfGame => 'Que tipo de jogo?';

  @override
  String get whoAreYou => 'Quem es?\\nSeleciona acima ⬆ ou entra abaixo ⬇';

  @override
  String get wizardStepOneOfTwo => 'Passo 1 de 2';

  @override
  String get wizardStepTwoOfTwo => 'Passo 2 de 2';

  @override
  String get youAreDone => 'Terminaste.';

  @override
  String get youIndicator => 'TU>';
}
