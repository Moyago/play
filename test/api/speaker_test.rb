require File.expand_path("../../helper", __FILE__)

context "api/speaker" do

  setup do
    Airfoil.app.get
    @speaker = Speaker.new "com.rogueamoeba.airfoil.LocalSpeaker"
  end

  test "/speakers" do
    get "/speakers"
    response_json = JSON.parse(last_response.body.strip)

    assert response_json["speakers"].length > 0

    speaker = response_json["speakers"][0]

    assert_equal @speaker.id, speaker["id"]
    assert_equal @speaker.name, speaker["name"]
    assert_equal @speaker.connected?, speaker["connected"]
    assert_equal @speaker.volume, speaker["volume"]
  end

  test "/speaker" do
    get "/speaker/#{@speaker.id}"
    response_json = JSON.parse(last_response.body.strip)
    speaker = response_json["speaker"]

    assert_equal @speaker.id, speaker["id"]
    assert_equal @speaker.name, speaker["name"]
    assert_equal @speaker.connected?, speaker["connected"]
    assert_equal @speaker.volume, speaker["volume"]
  end

  test "/speaker/:id/volume" do
    @speaker.volume = 0
    put "/speaker/#{@speaker.id}/volume", :volume => 1
    response_json = JSON.parse(last_response.body.strip)

    speaker = response_json["speaker"]
    assert_equal 1, speaker["volume"]
  end

  test "/speaker/:id/connect" do
    @speaker.disconnect!
    assert_equal false, @speaker.connected?

    put "/speaker/#{@speaker.id}/connect"
    response_json = JSON.parse(last_response.body.strip)

    speaker = response_json["speaker"]
    assert_equal true, speaker["connected"]
  end

  test "/speaker/:id/disconnect" do
    @speaker.connect!
    assert @speaker.connected?

    put "/speaker/#{@speaker.id}/disconnect"
    response_json = JSON.parse(last_response.body.strip)

    speaker = response_json["speaker"]
    assert_equal false, speaker["connected"]
  end

  test "/volume" do
    Airfoil.speakers_volume = 0
    put "/volume", :volume => 1
    response_json = JSON.parse(last_response.body.strip)

    assert response_json.keys.include?("speakers")
    assert response_json["speakers"].length > 0

    response_json["speakers"].each do |speaker|
      assert_equal 1, speaker["volume"]
    end
  end

end if Airfoil.installed? and ENV['CI'] != '1'
