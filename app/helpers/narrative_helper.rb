module NarrativeHelper
  def fake_narrative_content
    '<p>' + 5.times.map { 20.times.map { Faker::Lorem.sentence(10) }.join(' ') }.join('</p><p>') + '</p>'
  end
end
