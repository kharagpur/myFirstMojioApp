MojioClient = @MojioClient

# make sure you record your redirect_uri on your production account's app record in the developer center.
config = {
    application: 'f201b929-d28c-415d-9b71-8112532301cb', # Replace with your application id
    secret: 'f0927a0a-386b-4148-be8d-5ffd7468ea6b', # Replace with your secret id
    hostname: 'api.moj.io',
    version: 'v1',
    port: '443',
    scheme: 'https',
    login: 'anonymous@moj.io', # Replace with your login
    password: 'Password007' # Replace with your password
};

mojio_client = new MojioClient(config)
App = mojio_client.model('App')
$( () ->

    if (config.application == '[YOUR APP ID GOES HERE]')
        div = document.getElementById('result')
        div.innerHTML += 'Mojio Error:: Set your application and secret keys in myFirstMojioApp source code.  <br>'
        return

    mojio_client.login(config.login, config.password, (error, result) ->
        if (error)
            alert("Login Error:"+error)
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
