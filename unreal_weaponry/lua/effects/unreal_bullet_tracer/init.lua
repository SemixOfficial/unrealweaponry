EFFECT.Speed					= 18000;
local TRACER_MATERIAL			= Material("effects/bullet_tracer");
local TRACER_TAIL_MATERIAL		= Material("effects/smoke_trail");
local TRACER_FLAG_USEATTACHMENT	= 0x0002;

function EFFECT:GetTracerOrigin(data)
	-- this is almost a direct port of GetTracerOrigin in fx_tracer.cpp
	local start = data:GetStart();

	-- use attachment?
	if(bit.band(data:GetFlags(), TRACER_FLAG_USEATTACHMENT) == TRACER_FLAG_USEATTACHMENT) then
		local entity = data:GetEntity();
		if(not IsValid(entity)) then return start; end
		if(not game.SinglePlayer() and entity:IsEFlagSet(EFL_DORMANT)) then return start; end

		if(entity:IsWeapon() and entity:IsCarriedByLocalPlayer()) then
			-- can't be done, can't call the real function
			-- local origin = weapon:GetTracerOrigin();
			-- if(origin) then
			-- 	return origin, angle, entity;
			-- end
			
			-- use the view model
			local pl = entity:GetOwner();
			if(IsValid(pl)) then
				local vm = pl:GetViewModel();
				if(IsValid(vm) and not LocalPlayer():ShouldDrawLocalPlayer()) then
					entity = vm;
				else
					-- HACK: fix the model in multiplayer
					if(entity.WorldModel) then
						entity:SetModel(entity.WorldModel);
					end
				end
			end
		end

		local attachment = entity:GetAttachment(data:GetAttachment());
		if(attachment) then
			start = attachment.Pos;
		end
	end

	return start;
end

function EFFECT:Init(data)
	self.StartPos		= self:GetTracerOrigin(data);
	self.EndPos			= data:GetOrigin();
	self.CreationTime	= SysTime();
	self.LifeTime		= (self.StartPos - self.EndPos):Length() / (self.Speed * GetConVar("host_timescale"):GetFloat());
end

function EFFECT:Think()
	return self.LifeTime >= (SysTime() - self.CreationTime);
end

function EFFECT:Render()
	local interpFraction = (SysTime() - self.CreationTime) / self.LifeTime;
	if (interpFraction > 1) then
		interpFraction = 1;
	end

	local renderOrigin = LerpVector(interpFraction, self.StartPos, self.EndPos);
	local haha = (self.StartPos - self.EndPos):GetNormalized() * 128;

	render.SetMaterial(TRACER_MATERIAL);
	render.DrawBeam(renderOrigin + haha, renderOrigin, 12, 0, 1, Color(255, 255, 255, 255));

	render.SetMaterial(TRACER_TAIL_MATERIAL);
	render.DrawBeam(self.StartPos, renderOrigin + haha, 12, 0, 1, Color(255, 255, 255, 55 * (1 - interpFraction)));
end
