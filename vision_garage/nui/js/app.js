$(window).ready(function () {
  window.addEventListener("message", function (event) {
    let data = event.data;

    if (data.showMenu) {
      $("#container").fadeIn();
      $("#menu").fadeIn();

      if (data.vehiclesList != undefined) {
        $("#container").data("spawnpoint", data.spawnPoint);
        
        $(".content .vehicle-list").html(
          getVehicles(data.locales, data.vehiclesList)
        );

        $(".content h2").hide();
      } else {
        $(".content h2").show();
        $(".content .vehicle-list").empty();
      }

      $(".vehicle-listing").html(function (i, text) {
        return text.replace("Model", data.locales.veh_model);
      });
      $(".vehicle-listing").html(function (i, text) {
        return text.replace("Plate", data.locales.veh_plate);
      });
    } else if (data.hideAll) {
      $("#container").fadeOut();
    }
  });

  $("#container").hide();

  $(".close").click(function (event) {
    $("#container").hide();
    $.post("https://vision_garage/escape", "{}");

    $(".content").show();
  });

  document.onkeyup = function (data) {
    if (data.which == 27) {
      $.post("https://vision_garage/escape", "{}");

      $(".content").show();
      $('li[data-page="garage"]').addClass("selected");
    }
  };

  function getVehicles(locale, vehicle) {
    let html = "";
    let vehicleData = JSON.parse(vehicle);
    let bodyHealth = 1000;
    let engineHealth = 1000;
    let tankHealth = 1000;

    for (let i = 0; i < vehicleData.length; i++) {
      bodyHealth = (vehicleData[i].props.bodyHealth / 1000) * 100;
      engineHealth = (vehicleData[i].props.engineHealth / 1000) * 100;
      tankHealth = (vehicleData[i].props.tankHealth / 1000) * 100;

      vehicleDamagePercent =
        Math.round(((bodyHealth + engineHealth + tankHealth) / 300) * 100) +
        "%";

      html += "<div class='vehicle-listing'>";
      html += "<img src='image.png' alt='picture' style='width:100px;height:auto;margin-bottom:10px;'>";
      html += "<div>Auto: <strong>" + vehicleData[i].model + "</strong></div>";
      html += "<div>Kennzeichen: <strong>" + vehicleData[i].plate + "</strong></div>";
      html +=
        "<button data-button='spawn' class='vehicle-action unstyled-button' data-vehprops='" +
        JSON.stringify(vehicleData[i].props) +
        "'>" +
        locale.action +
        "</button>";
      html += "</div>";
    }

    return html;
  }

  $(document).on(
    "click",
    "button[data-button='spawn'].vehicle-action",
    function (event) {
      let spawnPoint = $("#container").data("spawnpoint");
      let vehicleProps = $(this).data("vehprops");

      $.post(
        "https://vision_garage/spawnVehicle",
        JSON.stringify({
          vehicleProps: vehicleProps,
          spawnPoint: spawnPoint,
        })
      );

      $(".content").show();
    }
  );
});
