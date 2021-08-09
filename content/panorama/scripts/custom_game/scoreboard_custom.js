//pass in hero portrait
function AddDebugScore(heroName, score)
{
    var panel = $.CreatePanel('Panel', $('#Scores'), '');
    //panel.SetHasClass("Scoreboard", true); // or false to hide it
    //can use this to override the css properties
    panel.BLoadLayoutSnippet("ScoreHero");
    /*panel.style.width = "150px";
    panel.style.height = "100px";
    panel.style.backgroundColor = "red";*/
    panel.FindChildTraverse("HeroImage").heroname = "npc_dota_hero_abaddon";

    //loop through players
    //add their portrait and score one by one
    //update their score when they score

}

function debug()
{
    
    //GameEvents.Subscribe("cookie_god_selection_end", OnCookieGodSelectionEnd);
    $.Msg("debug");
    AddDebugScore("red", 0);
    AddDebugScore("purple", 1);
}

GameEvents.Subscribe("pick_game", debug);
