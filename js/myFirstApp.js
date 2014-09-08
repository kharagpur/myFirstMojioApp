(function () {
    var MojioClient, config, mojio_client;

    MojioClient = this.MojioClient;

    config = {
        application: '[Your Application Id Here]',
        secret: '[Your Secret Key Here]',
        hostname: 'api.moj.io',
        version: 'v1',
        port: '80'
    };

    mojio_client = new MojioClient(config);

    mojio_client.login('[A Username or Email Here]', '[Password Here]', function (error, result) {
        if (error) {
            return alert("error:" + error + " \n\nMake sure you have put into the code your application id, secret, username and password (in square brackets [] in the code).");
        } else {
            mojio_client.get(mojio_client.model("User"), {id: result.UserId},
                function (error, result) {
                    var div, message;

                    message = 'Viewing the location of <strong>';

                    if (result.FirstName) {
                        message += result.FirstName;
                    } else if (result.UserName) {
                        message += result.UserName;
                    } else if (result.LastName) {
                        message += result.LastName;
                    } else {
                        message += "Unknown";
                    }
                    message += '</strong>';

                    div = $("#welcome");
                    div.html(message);
                });

            mojio_client.get(mojio_client.model("Vehicle"), {}, function (error, result) {
                var div, lat = [], lng = [], i = 0;

                $.each(result, function (key, value) {
                    if (value.LastLocation) {
                        lat[i] = value.LastLocation.Lat;
                        lng[i] = value.LastLocation.Lng;
                    }

                    i++;
                });

                div = $("#result");
                if (lat.length > 0) {
                    div.html('The vehicle is at: ' + lat[0] + ", " + lng[0]);
                    buildMojioMap(lat[0], lng[0]);
                } else {
                    div.html("No vehicle detected!");
                }

            });
        }
    });

}).call(this);

function buildMojioMap(mojioLat, mojioLng) {
    //Initialize Map
    map = new GMaps({
        el: '#map',
        lat: mojioLat,
        lng: mojioLng,
        panControl: false,
        streetViewControl: false,
        mapTypeControl: false,
        overviewMapControl: false,
    });

    //Add the marker
    setTimeout(function () {
        map.addMarker({
            lat: mojioLat,
            lng: mojioLng,
            animation: google.maps.Animation.DROP,
            draggable: false,
            title: 'Current Mojio Location'
        });
    }, 1000);
}