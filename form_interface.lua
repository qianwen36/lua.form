local form = {_tag = 'form'}
function form.build(tag, super)
--[[
	-- form to produce the target with super functional table and integrating multi-interface implement feature
	-- produce a target and hold following feature
	target:spec(interface) -- integrating the interface feature
	target:spec(name, property) -- property holder
	target:on(other) -- binding feature to other target and produce a delegater
--]]end

function form.on(target, spec)
--[[
	-- produce a delegater binding target feature with itself from spec, that the feature defined in spec
--]]end

function form.spec(target)
--[[
	--attach a form feature to the target

	--if target builded from `form.build`
	function target:spec(interface)
		-- specify target reuse interface code
	end
	--following feature is flexible
	function target:spec(prop, target)
		-- specify target property initial value and produce getter/setter
		-- example
		-- target:spec('prop', property)
		-- target:prop() return the property
		-- target:prop(property) to set the property
		-- target:spec('feature', interface)
		-- target:spec('feature') return the interface delegater binding on the target
	end

	-- if target is a interface implementation of a certain specification
	local spec = target
	function spec:on(target)
		-- produce the interface delegater binding on the target from spec
	end
--]]end
