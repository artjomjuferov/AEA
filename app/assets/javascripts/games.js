$(".linkRequest").click(function () {
  //$(this).attr("href");
  alert("fasd");
});

if (window.currentUser)
{
  PrivatePub.subscribe("/request/"+window.currentUser.id, function(data, channel) {
    main = $("#gamesRequest");
    if (data.stage == "req"){
      main.append('<div id="game'+data.id+'"></div>');
      obj = $("#game"+data.id);
      obj.append("want to play with " + data.id);
      obj.append(linkYes(data.id));
      obj.append(linkNo(data.id));
    } else if (data.stage == 'answ'){
      obj = $("#game"+data.id).empty;
      if (data.answer == 'yes'){
        obj.append("Let's play");
      }else{
        alert('No '+data.id );
        obj.append("Sorry");
      }
    } else if (data.stage == 'sent'){
      main.append('<div id="game'+data.id+'"></div>');
      obj = $("#game"+data.id);
      obj.append('Waiting for '+data.id);
    }
  });
}

function linkYes(id){
  html = '<a href="/games/'+id+'/edit"'; 
  html += 'data-remote="true" stage="answ" answer="yes">';
  html += 'Yes'; 
  html += '</a>';
  return html;
}

function linkNo(id){
  html = '<a href="/games/'+id+'/edit"'; 
  html += 'data-remote="true" stage="answ" answer="no">';
  html += 'No';
  html += '</a>';
  return html;
}
