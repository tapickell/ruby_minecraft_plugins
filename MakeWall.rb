Plugin.is {
  name "MakeWall"
  version "0.1"
  author "Todd Pickell"
  commands :wall => {
    :usage => "/wall - creates a wall of stone 3 high and 3 wide"
  },
  :dig => {
    :usage => "/dig depth - creates a hole 3 high and 3 wide"
  },
  :gimme => {
    :usage => "/gimme item number - gives you the item corresponding to the number"
  },
  :bridge => {
    :usage => "/bridge length - builds bridge just below feet level to length given"
  },
  :extinguish => {
    :usage => "/extinguish - extinguishes player if they are currently on fire"
  },
  :heal => {
    :usage => "/heal - heals player to max health"
  },
  :nomnom => {
    :usage => "/nomnom - feeds player"
  },
  :dora => {
    :usage => "/dora - resets players air to max and heals them"
  },
  :suitup => {
    :usage => "/suitup - gives player full armor"
  },
  :highbeams => {
    :usage => "/highbeams - grants night vision potion effect"
  },
  :item_names => {
    :usage => "/item_names - lists available names that can be used instead of item numbers"
  },
  :bow_of_awesomeness => {
    :usage => "/bow_of_awesomeness - grants bow with flaming arrows"
  },
  :sword_of_sweetness => {
    :usage => "/sword_of_sweetness - grants sword with flames and powers"
  },
  :pickaxe_of_plentiful => {
    :usage => "/pickaxe_of_plentiful - grants pickaxe with powers"
  }
}

import 'org.bukkit.inventory.ItemStack'
import 'org.bukkit.potion.PotionEffectType'
import 'org.bukkit.potion.PotionEffect'
import 'org.bukkit.enchantments.Enchantment'

class MakeWall < RubyPlugin
  def onEnable; print "The MakeWall plugin is enabled."; end
  def onDisable; print "The MakeWall plugin is disabled."; end

  def onCommand(sender, command, label, args)
    case command.name
    when "wall"
      Wall.new(sender, args.first).build
      true
    when "dig"
      Tunnel.new(sender, args.first).build
      true
    when "gimme"
      item_type = args.first || 50
      quantity = 64
      sender.send_message "Giving item..."
      give_item(sender, item_to_number(item_type), quantity)
      true
    when "bridge"
      Bridge.new(sender, agrs.first).build
      true
    when "extinguish"
      sender.send_message "Fire Bad!!!"
      sender.set_fire_ticks 0
      heal(sender)
      true
    when "heal"
      heal(sender)
      true
    when "nomnom"
      sender.send_message "Nom, Nom, Nom..."
      sender.set_food_level 20
      true
    when "dora"
      sender.send_message "Just keep swimming..."
      sender.set_remaining_air(sender.get_maximum_air)
      heal(sender)
      true
    when "suitup"
      sender.send_message "Time to get to work..."
      items = (310..313).each_with_object([]) { |item_number, array| array << ItemStack.new(item_number) }
      items.each do |item|
        item.addEnchantment(Enchantment::PROTECTION_EXPLOSIONS, Enchantment::PROTECTION_EXPLOSIONS.get_max_level)
        item.addEnchantment(Enchantment::PROTECTION_PROJECTILE, Enchantment::PROTECTION_PROJECTILE.get_max_level)
        item.addEnchantment(Enchantment::PROTECTION_FIRE, Enchantment::PROTECTION_FIRE.get_max_level)
        item.addEnchantment(Enchantment::THORNS, Enchantment::THORNS.get_max_level)
      end
      sender.get_equipment.set_armor_contents(items)
      true
    when "highbeams"
      sender.send_message "Excuse me sweetie, Your headlights are on..."
      sender.add_potion_effect(PotionEffect.new(PotionEffectType::NIGHT_VISION, 10000, 1))
      true
    when "bow_of_awesomeness"
      sender.send_message "Granting Bow of Awesomeness"
      bow = ItemStack.new(item_to_number("bow"))
      bow.add_enchantment(Enchantment::ARROW_FIRE, Enchantment::ARROW_FIRE.get_max_level)
      bow.add_enchantment(Enchantment::ARROW_INFINITE, Enchantment::ARROW_INFINITE.get_max_level)
      bow.add_enchantment(Enchantment::ARROW_DAMAGE, Enchantment::ARROW_DAMAGE.get_max_level)
      bow.add_enchantment(Enchantment::ARROW_KNOCKBACK, Enchantment::ARROW_KNOCKBACK.get_max_level)
      sender.set_item_in_hand(bow)
      true
    when "sword_of_sweetness"
      sender.send_message "Granting Sword of Sweetness"
      sword = ItemStack.new(item_to_number("sword"))
      sword.add_enchantment(Enchantment::DAMAGE_ALL, Enchantment::DAMAGE_ALL.get_max_level)
      sword.add_enchantment(Enchantment::FIRE_ASPECT, Enchantment::FIRE_ASPECT.get_max_level)
      sword.add_enchantment(Enchantment::DURABILITY, Enchantment::DURABILITY.get_max_level)
      sword.add_enchantment(Enchantment::KNOCKBACK, Enchantment::KNOCKBACK.get_max_level)
      sword.add_enchantment(Enchantment::LOOT_BONUS_MOBS, Enchantment::LOOT_BONUS_MOBS.get_max_level)
      sender.set_item_in_hand(sword)
      true
    when "pickaxe_of_plentiful"
      sender.send_message "Granting Pickaxe of Plentiful"
      pickaxe = ItemStack.new(item_to_number("pickaxe"))
      pickaxe.add_enchantment(Enchantment::DIG_SPEED, Enchantment::DIG_SPEED.get_max_level)
      pickaxe.add_enchantment(Enchantment::DURABILITY, Enchantment::DURABILITY.get_max_level)
      pickaxe.add_enchantment(Enchantment::LOOT_BONUS_BLOCKS, Enchantment::LOOT_BONUS_BLOCKS.get_max_level)
      sender.set_item_in_hand(pickaxe)
      true
    when "item_names"
      sender.send_message "Items: #{PluginUtils::items}"
      true
    else
      false
    end
  end
end

module Spells
  def heal(sender)
    sender.send_message "Healing..."
    sender.set_health(sender.get_max_health)
  end

  def give_item(sender, item_number, quantity)
    item_number, quantity = Integer(item_number), Integer(quantity)
    sender.set_item_in_hand(ItemStack.new(item_number, quantity))
  end
end

class Wall
  include PluginUtils
  def initialize(sender, item_type=1)
    @sender = sender
    @item_type = item_to_number(item_type)
  end

  def build
    @sender.send_message "Building Wall..."
    change_blocks(get_environment(@sender.get_location), item_to_number(@item_type), 1)
  end
end

class Tunnel
  include PluginUtils
  def intialize(sender, depth=3)
    @sender, @depth = sender, depth
  end

  def build
    sender.send_message "Digging tunnel #{depth} blocks deep..."
    break_blocks(get_environment(sender.get_location), depth)
  end
end

class Bridge
  include PluginUtils
  def intialize(sender, length=5)
    @sender, @length = sender, length
  end

  def build
    sender.send_message "Building bridge #{@length} blocks long..."
    starting_location = @sender.get_location
    starting_location.set_y(starting_location.get_y - 1)
    change_blocks(get_environment(starting_location), item_to_number('stone'), @length, 1)
  end
end

module PluginUtils
  @items_hash = {
    "stone" => 1,
    "grass" => 2,
    "dirt" => 3,
    "cblstone" => 4,
    "sand" => 12,
    "gravel" => 13,
    "glass" => 20,
    "sndstone" => 24,
    "goldblock" => 41,
    "ironblock" => 42,
    "brick" => 45,
    "tnt" => 46,
    "bkshelf" => 47,
    "diablock" => 57,
    "wdoor" => 64,
    "pplate" => 70,
    "idoor" => 71,
    "snow" => 80,
    "clay" => 82,
    "glow" => 89,
    "cake" => 92,
    "stndglass" => 95,
    "stonebrick" => 98,
    "quartzblock" => 155,
    "hay" => 170,
    "packedice" => 174,
    "bow" => 261,
    "arrows" => 262,
    "sign" => 323,
    "bucket" => 326,
    "saddle" => 329,
    "firecharge" => 385,
    "sword" => 276,
    "pickaxe" => 278,
    "lead" => 420
  }

  def item_names
    @items_hash.keys
  end

  def item_to_number(item)
    return @items_hash.fetch(item) if @items_hash.include? item
    Integer(item)
  end

  def blocks_in_area(env, offset, depth, height)
    depth = Integer(depth)
    width = 3
    height.times do |delta_y|
      width.times do |delta_left_right|
        delta_a = delta_left_right - 1
        depth.times do |delta_front|
          delta_b = delta_front + offset
          floored_x = env.fetch(:location).x.floor
          floored_z = env.fetch(:location).z.floor

          block_y = env.fetch(:location).y.floor + delta_y
          block_x, block_z = case env.fetch(:direction)
                             when :north
                               [delta_a + floored_x, (floored_z - delta_b)]
                             when :south
                               [delta_a + floored_x, (floored_z + delta_b)]
                             when :east
                               [(floored_x - delta_b), delta_a + floored_z]
                             when :west
                               [(floored_x + delta_b), delta_a + floored_z]
                             end
          yield env.fetch(:world).get_block_at(block_x, block_y, block_z)
        end
      end
    end
  end

  def change_blocks(env, type, depth, height=3)
    offset = 2
    blocks_in_area(env, offset, depth, height) { |block| block.set_type_id(type) }
  end

  def break_blocks(env, depth)
    offset, height = 1, 3
    blocks_in_area(env, offset, depth, height) { |block| block.break_naturally }
  end

  def get_environment(location)
    { :location => location, :world => location.get_world, :direction => facing_direction(location) }
  end

  def facing_direction(location)
    [:south, :west, :north, :east, :south][(location.yaw / 90.0).round.abs]
  end
end

