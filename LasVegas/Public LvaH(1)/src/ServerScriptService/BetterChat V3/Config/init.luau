--[[

  ___      _   _              ___ _         _         ____
 | _ ) ___| |_| |_ ___ _ _   / __| |_  __ _| |_  __ _|__ /
 | _ \/ -_)  _|  _/ -_) '_| | (__| ' \/ _` |  _| \ V /|_ \
 |___/\___|\__|\__\___|_|    \___|_||_\__,_|\__|  \_/|___/
 
Created by: @Jumpathy

Credits:
@Xsitsu - A few of the original chat functions such as user chat colors and chat cooldowns.
@qwreey74 - High quality material icons
@Blockzez - Hex color encode / decode functions
@boatbomber - Textbox+'s undo/redo system code concept
@boatbomber - Image masking for some user thumbnails
@ForeverHD - Topbar+
@Fm_Trick - Slider math help via public resource
@McThor2 - Math help for bubble chat
@sleitnick - Raycasting code for bubble chat
@alexinite - Contributing bug fixes and helping people in replies with their issues

]]

return {
	Permissions = {
		Ranks = { 
			--[[
				Ranks are like permissions for the chat, we can assign things 
				like editing message access to them if you don't want regular users
				to have those. They're not admin-commands, I've just named them in this
				manner to understand more effectively.
			--]]

			[1] = "Guest", --> Rank ID 1 will automatically be assigned to each user (the config below can determine their final permission level)
			[2] = "Casino Guest",
			[3] = "Regular",
			[4] = "Dedicated",
			[5] = "Addict",
			[6] = "Gold Club",
			[7] = "V.I.P",
			[8] = "Quality Assurance",
			[9] = "Contributor",
			[10] = "Moderator",
			[11] = "Developer" --> Automatically assigned to the group creator or game creator
		},
		Users = {
			--[1] = "Admin", --> Roblox -> Admin rank
		},
		Groups = {
			[game:GetService("ReplicatedStorage"):GetAttribute("GroupID")] = { --> Roblox admins get the admin rank automatically
				[0] = "Guest",
				[1] = "Casino Guest",
				[3] = "Regular",
				[4] = "Dedicated",
				[5] = "Addict",
				[101] = "Gold Club",
				[102] = "V.I.P",
				[103] = "Quality Assurance",
				[104] = "Contributor",
				[254] = "Moderator",
				[255] = "Developer"
			}
		},
		Gamepasses = {
			--[0] = "VIP" --> Gamepass 0 --> VIP rank
		},
		RobloxPremium = "Guest"
	},
	ChatTags = {
		MaxAmountTags = 1, --> Maximum amount of tags one user can have
		Users = {
			--[[["Roblox"] = { --> Assign Roblox a red 'Owner' tag
				{
					Text = "Owner",
					Color = Color3.fromRGB(255,0,0)
				}
			}--]]
		},
		Ranks = {
			[11] = { --> Assign the owner of the game with the chat a yellow owner tag
				{	
					Text = "Developer",
					Color = Color3.fromRGB(255, 100, 255),
					Priority = 11 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[10] = {
				{	
					Text = "Moderator",
					Color = Color3.fromRGB(255, 153, 253),
					Priority = 10 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[9] = {
				{	
					Text = "Contributor",
					Color = Color3.fromRGB(145, 66, 255),
					Priority = 9 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[8] = {
				{	
					Text = "Quality Assurance",
					Color = Color3.fromRGB(183, 135, 255),
					Priority = 8 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[7] = {
				{	
					Text = "V.I.P",
					Color = Color3.fromRGB(255, 100, 100),
					Priority = 7 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[6] = {
				{	
					Text = "Gold Club",
					Color = Color3.fromRGB(255, 255, 0),
					Priority = 6 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[5] = {
				{	
					Text = "Addict",
					Color = Color3.fromRGB(255, 85, 88),
					Priority = 5 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[4] = {
				{	
					Text = "Dedicated",
					Color = Color3.fromRGB(255, 195, 121),
					Priority = 4 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[3] = {
				{	
					Text = "Regular",
					Color = Color3.fromRGB(0, 123, 255),
					Priority = 3 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[2] = {
				{	
					Text = "Casino Guest",
					Color = Color3.fromRGB(111, 209, 255),
					Priority = 2 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			},
			[1] = {
				{	
					Text = "Guest",
					Color = Color3.fromRGB(255,255,255),
					Priority = 1 --> If you have a max amount of tags and one user goes over it, the tags with the lowest priority will be removed first.
				}
			}
		}
	},
	TextColors = {
		Ranks = {
			[11] = Color3.fromRGB(255, 175, 250) --> Assign the owner role a golden text color
		},
		Users = {
			--["Roblox"] = Color3.fromRGB(255,0,0) --> Assign Roblox a red chat color
		}
	},
	NameColors = {
		Ranks = {
			--[4] = Color3.fromRGB(255,255,0) --> Assign the owner of the game with a yellow name color
		},
		Users = {
			--["Roblox"] = Color3.fromRGB(255,0,0) --> Assign Roblox a red username
		}
	},
	UI = {
		ChatSizes = {
			Phone = UDim2.new(0.2,0,0.2,24); --> Chat size on phone
			Tablet = UDim2.new(0.4,0,0.3,24); --> Chat size on tablet
			Desktop = UDim2.new(0.3,0,0.25,24); --> Chat size on desktop
		},
		Fonts = {
			TextFont = Enum.Font.GothamMedium --> Every text's font in the chat
		},
		Colors = {
			SystemPrefixColor = Color3.fromRGB(253,80,111) --> Color of the prefix used for [Team] / [From: user]
		},
		FadeOptions = {
			Window = {
				HoveringTransparency = 0, --> Transparency of main window when hovering
				NotHoveringTransparency = 0.5 --> When not hovering
			},
			Chatbar = { --> Transparency of chatbar, resize button, channel button
				HoveringTransparency = 0,
				NotHoveringTransparency = 0.5,
				TextColor = { --> Chatbar text color when hovering
					Regular = {
						Hovering = Color3.fromRGB(100,100,100),
						NotHovering = Color3.fromRGB(255,255,255)
					},
					Placeholder = {
						Hovering = Color3.fromRGB(80,80,80),
						NotHovering = Color3.fromRGB(200,200,200)
					}
				}
			}
		},
		ColorOptions = {
			ChatbarColor = Color3.fromRGB(255,255,255),
			Buttons = {
				ResizeButton = { --> UI resize button
					BackgroundColor = Color3.fromRGB(52,52,52),
					IconColor = Color3.fromRGB(255,255,255)
				},
				ChannelButton = { --> Channel bar channel buttons: (also autofill too lol)
					BackgroundColor = Color3.fromRGB(0,0,0),
					TextColor = Color3.fromRGB(255,255,255)
				},
				AutofillButton = { --> Autofill buttons
					BackgroundColor = Color3.fromRGB(30,30,30),
					TextColor = Color3.fromRGB(255,255,255)
				},
				ReplyAndChannel = { --> On the chatbar, when whispering or replying this icon shows up
					BackgroundColor = Color3.fromRGB(253,80,111), --> 253,80,111
					TextAndIconColor = Color3.fromRGB(255,255,255)
				}
			},
			Window = {
				BackgroundColor = Color3.fromRGB(0,0,0),
			}
		},
		ChatWindowVisible = true, --> Is it just the chatbar visible?
		ChannelBarEnabled = true, --> Channel navigation bar at the top of the chat
		SeparateChatbarFromMenu = true, --> Do separate the chat bar from the main UI?
		Resizable = true, --> Can the user resize their chat?
		Rounding = 8, --> UI roundness in px
		BaseTextSize = 16, --> Base text size for the UI
		CornerPosition = "TopLeft" --> Chat corner position (BottomRight, TopLeft, TopRight, BottomLeft)
	},
	User = {
		ChangeDisplayNameColorWhenAttributeChanged = true, --> If you change their DisplayName at run time, will it also automatically update their name color?
		NameColors = { --> Default name colors
			Color3.fromRGB(253,41,67), --> Red
			Color3.fromRGB(1,162,255), --> Blue
			Color3.fromRGB(1,236,111), --> Green
			Color3.fromRGB(174,81,202), --> Purple
			Color3.fromRGB(255,154,76), --> Orange
			Color3.fromRGB(255,211,50), --> Yellow
			Color3.fromRGB(255,205,221), --> Pink
			Color3.fromRGB(255,234,183) --> Beige
		},
		SaveData = { --> Data saving for the options menu (uses ProfileService internally)
			Enabled = true, --> Enable data-saving for these? (Better user-experience if enabled)
			Advanced = { --> Recommend not changing if you don't know what you're doing.
				DatastoreName = "BetterChatV3Data", --> Changing this can reset any existing user data for the chat until you change it back
				HandleOwnData = false --[[
				Create a server addon and register these functions 
					:registerGetProfileFunction(<function:callback>) <plr> (return a table that will save data that's updated in it)
					:registerUnloadProfileFunction(<function:callback>) <plr>
				--]]
			}
		}
	},
	DisplayNames = {
		Enabled = true, --> Are player display names enabled (attribute for the player still works but it's not set initially)
	},
	Teams = {
		TeamColorPriority = true, --> Does team color override their natural chat color?
		TeamChat = true, --> Team chat?
	},
	Notifiers = {
		FriendJoinNotifier = true, --> Notify the user when their friend joins the game?
		TeamChangeNotifier = true, --> Notify the user when their team is changed?
		BlockedUserNotifier = true, --> Place a system message in the chat when a user is blocked?
	},
	Messages = {
		BlacklistEnabled = true, --> Do you want to enact a custom word blacklist?
		BlacklistCanUseDatastores = true, --> Enabling this allows API methods such as :blacklistWord(word <string>,state <bool>) which will save in live time
		BlacklistedWords = {}, --> Will be filtered automatically
		FilterProcessingCharacter = "_", --> What messages are replaced with before being properly filtered and distributed (whilst pending)
		IncludeIcon = true,	--> Display a player thumbnail next to their username in the chat
		UseViewportForIcon = true, --> Use a viewport frame for this? (Helpful for Roleplay games where your avatar isn't the same as it normally would be)
		MaximumLength = 200, --> Maximum allowed message length (> 1000 would probably just brick the chat)
		DisallowedWhitespace = {"\n","\r","\t","\v","\f"}, --> Filter these characters out of the messages to prevent breaking the chat
		ChannelMessageLimit = 50, --> Max amount of messages displayed in a channel at one time
		QuickChat = true, --> Quick chat system enabled?
		Cooldown = { --> This is the chat's antispam system.
			ExpireTimePeriod = 15, --> Maximum message cooldown length
			NumberMessageAllowed = 7 --> Maximum messages allowed in a pre-defined time period
		},
		Private = {
			WhispersEnabled = true --> Private messaging between users
		},
		Extra = {
			DeleteableMessages = "Moderator", --> Permission needed to delete messages
			Editable = "Moderator", --> Permission needed to edit messages by right clicking / clicking the text (leaves an '(edited)' stamp)
			MarkdownEnabled = "Gold Club", --> Permission needed to use markdown format, eg: **bold**
			ReplyEnabled = "Casino Guest", --> Permission needed to reply to a message
			MentionEnabled = "Casino Guest", --> Permission needed to mention another user in the chat
			MeCommand = "Gold Club" --> Permission needed to use the /me command
		},
		Markdown = {
			ItalicBold = true,
			Bold = true,
			Italics = true,
			Underlines = true,
			Strikethrough = true,
			Colored = true,
			Outlines = true,
			Fonts = true
		},
		MessageGrouping = {
			Enabled = false, --> Merge messages when sent by the same user back to back?
			GroupTimeout = 120 --> When do they split back up again?
		},
		CustomEmojis = {
			Enabled = false, --> Enable custom emojis?
			PermissionLocked = "Gold Club", --> Set to a rank such as "Owner" to enable custom emojis for specific users only
			ScaleType = Enum.ScaleType.Fit, --> Scale type for custom emoji images
			List = { --> Allowed formats: "id" or {"id","permission to lock it to"}
				["ban_hammer"] = {"rbxassetid://4813866018","Owner"},
				["troll"] = "rbxassetid://15828456252",
				["vibe_cat"] = { --> Vibe cat
					["Image"] = "rbxassetid://18495257138",
					["ImageRectSize"] = Vector2.new(68.2,68.2), --> Image dimensions / columns and rows
					["Columns"] = 5,
					["Rows"] = 15,
					["Frames"] = 71,
					["FPS"] = 15 --> Above this gets a little too fast to comprehend logically
				}
			}
		}
	},
	BubbleChat = {
		Enabled = true, --> Custom bubble chat enabled state (setting to false will default to the regular bubble chat which can be turned off in the properties of game.Chat)
		Config = {
			TypingIndicator = true, --> Some dots to indicate you're typing
			EasingStyle = Enum.EasingStyle.Bounce, --> The chat bubble's tween style
			Length = 0.16, --> The length per tween in the UI
			MaxMessages = 4, --> The max amount of bubble chat messages above one user's head at once
			FadeoutTime = 10, --> Message fading time
			TextSize = 16, --> This is the chat bubble's text size.
			Padding = 8, --> Padding in offset on each side of the message.
			BubbleFont = Enum.Font.GothamMedium, --> The chat bubble's primary font.
			TypingIndicatorColor = Color3.fromRGB(255,255,255), --> Player typing indicator color.
			BubbleBackgroundColor = Color3.fromRGB(20,20,20), --> The chat bubble's background color.
			BubbleTextColor = Color3.fromRGB(255,255,255), --> The chat bubble's text color.
			Roundness = 8, --> The chat bubble's roundness in pixels
		}
	},
	SettingsMenu = { --> Settings for the chat's interface
		Enabled = true, --> Do you want it to be enabled?
		ApiEnabledAndUIDisabled = false, --> Do you want to just enable the settings API for the client & disable the UI so you can design your own?
		TopbarButton = {
			Enabled = true, --> If it's enabled, do you want a topbar button for it? If not, you can use "/settings" to open the menu.
			Icon = "rbxassetid://8654540235" --> If you use the topbar button, what icon?
		}
	}
}