var numGamesIndex = 1;

var num_games_details = [
  {
    name: "#num_games_short",
  },
  {
    name: "#num_games_medium",
  },
  {
    name: "#num_games_long",
  },
];

function AddNumGames() {
  var panel = $.CreatePanel("Panel", $("#SelectionPanel"), "");

  panel.BLoadLayoutSnippet("NumGamesSnippet");
}

function OnNumGamesSelectionEnd() {
  HideNumGamesSelection();
}

function OnHighlightNumGames(index) {
  numGamesIndex = index;

    var num_games_detail = num_games_details[index];
    $("#NumGamesName").text = $.Localize(num_games_detail.name);

  //use Object.keys(hero_details).length to make it dynanic to the length of the "hero_details" dictionary
  for (var i = 0; i < Object.keys(num_games_details).length; i++) {
    if (i == index) {
      $("#NumGamesPanel" + index).style["backgroundColor"] = "#0000FF";
    } else {
      $("#NumGamesPanel" + i).style["backgroundColor"] = "#000000";
    }
  }
}


function OnNumGamesMouseOver(index) {

    $.DispatchEvent(
      "DOTAShowTitleTextTooltip",
      $("#NumGamesPanel" + index),
      $.Localize(num_games_details[index].name),
      $.Localize(num_games_details[index].name + "_lore")
    );
}


function OnNumGamesMouseOut(index) {
  $.DispatchEvent("DOTAHideTitleTextTooltip");
}


function OnSelectNumGames() {
  var num_games_options = ["short", "medium", "long"];

  var payload = {
    numGames: num_games_options[numGamesIndex],
  };

  // $.Msg("payload: " + JSON.stringify(payload));

  //payload gets passed to "gamemode"'s js function as "keys"
  GameEvents.SendCustomGameEventToServer("js_player_select_num_games", payload);

}


function HideNumGamesSelection() {
  $("#NumGamesSelectRoot").visible = false;
}

function ShowNumGamesSelection() {
  $("#NumGamesSelectRoot").visible = true;
}

function RunSelect() {
    //display like it used to
    GameEvents.Subscribe("num_games_to_play_selection_end", OnNumGamesSelectionEnd);
    //AddNumGames();
    OnHighlightNumGames(numGamesIndex);
    
}

RunSelect();
