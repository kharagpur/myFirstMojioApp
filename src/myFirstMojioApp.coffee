MojioClient = @MojioClient

# make sure you record your redirect_uri on your production account's app record in the developer center.
config = {
    application: '[YOUR APP ID GOES HERE]', # Fill in your app id here!
    redirect_uri: '[YOUR REDIRECT URI GOES HERE]', # Fill in your redirect uri here! (Ex.'http://localhost:63342/myFirstMojioApp/index.html')
    hostname: 'api.moj.io',
    version: 'v1',
    port: '443',
    scheme: 'https',
};

mojio_client = new MojioClient(config)
App = mojio_client.model('App')
$( () ->

    if (config.application == '[YOUR APP ID GOES HERE]')
        div = document.getElementById('result')
        div.innerHTML += 'Mojio Error:: Set your application and secret keys in myFirstMojioApp source code.  <br>'
        return
    if (config.application == '[YOUR REDIRECT URI GOES HERE]')
        div = document.getElementById('result')
        div.innerHTML += 'Mojio Error:: Set a redirect_uri in myFirstMojioApp source code.  <br>'
        return

    mojio_client.token((error, result) ->
        if (error)
            console.log("redirecting to login.")
            mojio_client.authorize(config.redirect_uri)
        else
            alert("Authorization Successful.")
            div = $("#welcome");
            div.html('Authorization Result:<br />')
            div.append(JSON.stringify(result))

            mojio_client.get(mojio_client.model("User"), {id: result.UserId}, (error, result) ->
                message = '<br/><br/>Viewing the location of <strong>'

                if (result.FirstName)
                    message += result.FirstName
                else if (result.UserName)
                    message += result.UserName
                else if (result.LastName)
                    message += result.LastName
                else if (result.Email)
                    message += result.Email
                else
                    message += "Unknown"

                message += '</strong>'

                div = $("#welcome")
                div.append(message)
            )

            mojio_client.get(mojio_client.model("Vehicle"), {}, (error, result) ->
                lat = []; lng = []; i = 0

                $.each(result.Data, (key, value) ->
                    if (value.LastLocation? and value.LastLocation.Lat? and value.LastLocation.Lng?)
                        lat[i] = value.LastLocation.Lat
                        lng[i] = value.LastLocation.Lng
                        i++
                )

                div = $("#result")
                if (lat.length > 0)
                    div.html('The vehicle is at: ' + lat[0] + ", " + lng[0])
                    buildMojioMap(lat[0], lng[0]);
                else
                    div.html("No vehicle detected!");
            )
    )
    $("#button").click( () ->
        mojio_client.unauthorize(config.redirect_uri)
    )
)


buildMojioMap = (mojioLat, mojioLng) ->
    # Initialize Map
    map = new GMaps (
        {
            el: '#map',
            lat: mojioLat,
            lng: mojioLng,
            panControl: false,
            streetViewControl: false,
            mapTypeControl: false,
            overviewMapControl: false,
        }
    )

    #Add the marker
    setTimeout( () ->
        map.addMarker (
            {
                lat: mojioLat,
                lng: mojioLng,
                animation: google.maps.Animation.DROP,
                draggable: false,
                title: 'Current Mojio Location'
            }
        ),
        1000
    )
