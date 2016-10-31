local form = {_tag = 'form'}
function form.build(tag, super)
    local target = {
    	_tag = tag,
    	_super = super
    }
    form.spec(target)
    setmetatable(target, form._meta())
    return target
end

function form.copy( target, ref )
	for k,v in pairs(ref) do
		local t = type(v)
		if t == 'function' then
			if (target[k] == nil) then
				target[k] = v
			end
		else
			target[k] = v
		end
	end
end
function form.on(target, spec) -- self 点式传参生成器 
	local tar = {_tag = form.tag(target)}
    local multiplexer = {}
    local multi_
    if spec == form then return target end

    for k,v in pairs(spec) do
	    if type(v) == 'function' then
	    	local method = spec[k]
	        tar[k] = function ( ... )
	            return method(target, ...)
	        end
	    end
	end
	multi_ = spec._interface or {}
	for i,v in ipairs(multi_) do
		local t = form.on(target, v)
		if t ~= target then
			form.copy(multiplexer, t)
		end
	end
	multi_ = spec._super or {}
	if next(multi_) ~= nil then
		local t = form.on(target, multi_)
		if t ~= target then
			form.copy(multiplexer, t)
		end
	end

	setmetatable(tar, {__index = multiplexer})

    return tar
end

function form.spec(target)
	local super = target._super or {}
	target.tag = target.tag or form.tag
	target.log = target.log or super.log or form.log

	if target.definition == nil
	and super.definition == nil then
	function target:definition( method, option )
		option = option or ''
		local tx = ' '..option..', not implemented'
		self:log(method, tx)
	end
	target:log(':definition( method, option ) produced')
	end
	if target.on == nil
	and super.on == nil then
	function target:on(target)
		local tar = {_tag = form.tag(target)}
		local spec = self
	    for k,v in pairs(spec) do
	        if type(v) == 'function' then
	            tar[k] = function ( ... )
	                spec[k](target, ...)
	            end
	        end
	    end
	    self:log('['..spec:tag()..'] target binding form produced')
	    -- no such key binding to the target
	    tar.on = nil
	    tar.spec = nil
	    return tar
	end
	end
	if target.spec == nil
	and super.spec == nil then
	function target:spec(prop, target)
		if  self._interface == nil then
			self._interface = {}
		end
	    local handler = {}
	    function handler.string(self, prop, target)
	        if target ~= nil then
	            self:log('['..prop..'] setter/getter produced')
	            local property = '__'..prop
	            local function prop_(self, target)
	                if target ~= nil then
	                    self[property] = target
	                    return self
	                end
	                return self[property]
	            end
	            prop_(self, target)[prop] = prop_
	            return target
	        end
	        if (type(self[prop]) == 'function') then
				local spec = self[prop](self)
				return spec and spec:on(self)
			end
	    end
	    function handler.table(self, prop)
	        local target = prop
	        table.insert(self._interface, target)
            self:log(' interface['..form.tag(target)..'] specified')
	        return self
	    end
	    handler = handler[type(prop)]
	    return handler and handler(self, prop, target)
	end
	target:log(':spec(prop, target) produced')
	end

	if target.super == nil
	and super.super == nil then
	function target:super()		-- just the final target can use this feature, extend limitation.(T_T)
		local super = self.__base -- make this property
		if super == nil then
			local super_ = self._super
			super = super_ and form.on(self, super_)
			self.__base = super
		end
		return super
	end
	target:log(':super() produced')
	end

	return target
end

function form:log( ... )
	print(self:tag()..table.concat({...}))
end

function form:tag()
	local tag = self._tag
	if type(tag)=='string'
	then
		return '*'..tag..'*'
	end
	return 'none.TAG'
end

function form._meta()
    local meta = {__index = true} -- predefine
    function meta.__index(target, key)
    	-- avoid target._interface rise to C stack overflow, .etc
    	-- following anonymous table specify the key filters
    	if ({_interface = true, _super = true})[key] then return nil end

        local super = target._super
        local interface = target._interface
        local v = super and super[key]
        if v == nil and type(interface)=='table'
        then
            for i=1, #interface do
                v = interface[i][key]
                if v ~= nil then return v end
            end
        end
        return v
    end
    return meta
end

return form