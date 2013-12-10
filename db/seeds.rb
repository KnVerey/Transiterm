# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

LanguagePair.create(language1: "English", language2: "French")
LanguagePair.create(language1: "English", language2: "Spanish")
LanguagePair.create(language1: "French", language2: "Spanish")