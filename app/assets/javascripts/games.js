if (window.currentUser)
{
  PrivatePub.subscribe("/request/"+window.currentUser.id, function(data, channel) {
    main = $("#gamesRequest");
    if (data.stage == "exist"){
      obj = $("#userInTable"+data.id);
      obj.find(".userStatus").empty();
      obj.append('Game or Requesst already exist');
      
    } else if (data.stage == "buzy"){
      obj = $("#userInTable"+data.id);
      obj.find(".userStatus").empty();
      obj.append('Sorry he is in game');
    } else if (data.stage == "req"){
      main.append('<div id="game'+data.id+'"></div>');
      obj = $("#game"+data.id);
      obj.append("want to play with " + data.id);
      obj.append(linkYes(data.id,"answ"));
      obj.append(linkNo(data.id,"answ"));
    }else if (data.stage == 'answ'){
      obj = $("#game"+data.id).empty;
      obj.append("Won");
      obj.append(linkYes(data.id,"result"));
      obj.append(linkNo(data.id,"result"));
    } else if (data.stage == 'sent'){
      main.append('<div id="game'+data.id+'"></div>');
      obj = $("#game"+data.id);
      obj.append('Waiting for '+data.id);
    }
  });
}

function linkYes(id, stage){
  html = '<a href="/games/'+id+'/edit"'; 
  html += 'data-remote="true" stage="'+answ+'" answer="yes">';
  html += 'Yes'; 
  html += '</a>';
  return html;
}

function linkNo(id){
  html = '<a href="/games/'+id+'/edit"'; 
  html += 'data-remote="true" stage="'+answ+'" answer="no">';
  html += 'No';
  html += '</a>';
  return html;
}
