if (window.currentUser)
{
  PrivatePub.subscribe("/request/"+window.currentUser.id, function(data, channel) {
    $("#requestGames").load("/games/show_all");
  });
}

/*
function linkYes(id, stage){
  html = '<a data-remote="true" '; 
  html += 'href="/games/'+id+'/edit?stage='+stage+'&answer=yes">';
  html += 'Yes'; 
  html += '</a>';
  return html;
}

function linkNo(id, stage){
  html = '<a data-remote="true" '; 
  html += ' href="/games/'+id+'/edit?stage='+stage+'&answer=no">';
  html += 'No';
  html += '</a>';
  return html;
}

// $.ajax({
       //    method: "POST",
       //    url: "/status",
       //    data: {uuids: '<%= @uuid_hash.to_json %>'},
       //    },
       //    success: function(data){
       //        var obj = $.parseJSON(data);
       //        if(obj.isDone == "yes"){

       //        }else{
       //            obj.each(function(result) { 
       //              if(result.status == "completed"){
       //                 $('a[href="#{result.url}"]').html('');
       //              }
       //            });
       //            pollingAJAX();
       //        }    
       //    }
      //}); 
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
      if (data.answer == "yes"){
        obj = $("#game"+data.id).empty();
        alert("YES");
        obj.append("Won");
        obj.append(linkYes(data.id,"result"));
        obj.append(linkNo(data.id,"result"));
      } else {
        if (data.id)
        obj = $("#game"+data.id).empty();
        alert("NO he don't want to play");
      }

    } else if (data.stage == 'sent'){
      main.append('<div id="game'+data.id+'"></div>');
      obj = $("#game"+data.id);
      obj.append('Waiting for '+data.id);
    }*/
