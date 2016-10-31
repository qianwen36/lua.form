local form = require('form')

local base = form.build('base')

function base:test()
	print('base:test()')
	self:log(':test()')
end

local variant = form.build('variant', base)

function variant:lazy()
	print('variant:lazy()')
	self:log(':lazy()')
end

local target = form.build('target', variant)

function target:lazy()
	self:super().lazy()
	self:log(':lazy()')
end

function target:test()
	self:super():test()
	self:log(':test()')
end

target:test()

target:lazy()
