function setIntervalTest(onSuccess) {
  var i=0;
  var starTime = new Date().getTime();
  var interval = window.setInterval(function () {
  
    NativeBridge.call("setBackgroundColor", [0,0,i++/255]);
    
    document.getElementById("count").innerHTML = i;
    document.getElementById("count2").textContent = i;
    
    if (i==255) {
      document.body.innerHTML += "SetInterval executed in "+(new Date().getTime()-starTime)+" ms<br/>";
      window.clearInterval(interval);
      if (onSuccess)
        onSuccess();
    }
    
  },0);
}

function callbackLoopTest(onSuccess) {
  var starTime = new Date().getTime();
  var i=0;
  function loop() {
    try {
      if (i>255) {
        document.body.innerHTML += "Loop executed in "+(new Date().getTime()-starTime)+" ms<br/>";
        if (onSuccess)
          onSuccess();
        return;
      }
      document.getElementById("count").innerHTML = i;
      document.getElementById("count2").textContent = i;
    
      NativeBridge.call("setBackgroundColor", [0,0,i++/255], function () {
        loop();
      });
    } catch(e) {
      alert(e);
    }
  };
  loop();
}

function promptTest(onSuccess) {
  NativeBridge.call("setBackgroundColor", [0,0,1]);
  window.setTimeout(function () {
    NativeBridge.call("prompt", ["do you see blue background ?"],function (response){
      if (response) {
        document.body.innerHTML+="<br/>You saw blue background, all is perfectly fine!<br/>";
      } else {
        document.body.innerHTML+="<br/>Are you sure ? Because you have to see blue!<br/>";
      }
      if (onSuccess)
        onSuccess();
    });
  }, 600);
}

function addElement(index, number){

	// This is the <ul id="myList"> element that will contains the new elements
	var container = document.getElementById('outputList');

	// Create a new <li> element for to insert inside <ul id="myList">
	var new_element = document.createElement('li');
	new_element.innerHTML = index + ": " + number;
	container.insertBefore(new_element, container.firstChild);

}

function AccelLoopTest(onSuccess) {
    var starTime = new Date().getTime();
    var i=0;
    function loop() {
    	i++;
        try {
            if (i>255) {
                document.body.innerHTML += "Loop executed in "+(new Date().getTime()-starTime)+" ms<br/>";
                if (onSuccess)
                    onSuccess();
                return;
            }
            document.getElementById("count").innerHTML = i;
            
            NativeBridge.call("readDeviceData", [0], function (number) {
                              addElement(i, number);
                              loop();
                              });
        } catch(e) {
            alert(e);
        }
    };
    loop();
}

window.addEventListener("load",function () {
  try {
    
    AccelLoopTest(function () {
        promptTest();
      });
      
    
  } 
  catch(e){
    alert(e);
  }
},false);

