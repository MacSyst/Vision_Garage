Config = {}

Config.Locale = 'en'

Vision = {}

Vision.Debug = true -- Enable this for debugging file Name
Vision.DrawDistance = 10.0 -- Distance from player to show marker
Vision.DiscordNotify = true -- Enable this for Webook
Vision.Webhook = '' -- Insert your Webhook here

Vision.Markers = {
	EntryPoint = {
		Type = 21,
		Size = {
			x = 1.0,
			y = 1.0,
			z = 0.5,
		},
		Color = {
			r = 87,
			g = 0,
			b = 145,
		},
	},
	GetOutPoint = {
		Type = 21,
		Size = {
			x = 1.0,
			y = 1.0,
			z = 0.5,
		},
		Color = {
			r = 87,
			g = 0,
			b = 145,
		},
	},
}

Vision.Garages = {
	VespucciBoulevard = {
		EntryPoint = {
			x = -285.2,
			y = -886.5,
			z = 31.0,
		},
		SpawnPoint = {
			x = -309.3,
			y = -897.0,
			z = 31.0,
			heading = 351.8,
		},
		Sprite = 357,
		Scale = 0.8,
		Colour = 27,
	},
	LegionSquare = {
		EntryPoint = {
			x = 216.4,
			y = -786.6,
			z = 30.8,
		},
		SpawnPoint = {
			x = 218.9,
			y = -779.7,
			z = 30.8,
			heading = 338.8,
		},
		Sprite = 357,
		Scale = 0.8,
		Colour = 27,
	},
}

exports("getGarages", function()
	return Vision.Garages
end)
