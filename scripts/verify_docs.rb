# frozen_string_literal: true

require "json"
require "pathname"

api_path = Pathname(ARGV.fetch(0)).expand_path
root = Pathname(ARGV.fetch(1, ".")).expand_path

required_files = %w[
  README.md
  LICENSE
  CHANGELOG.md
  COMPATIBILITY.md
  SECURITY.md
  CONTRIBUTING.md
  docs/API.md
  docs/GUIDE.md
  docs/ARCHITECTURE.md
  docs/MIGRATION.md
  docs/PERFORMANCE.md
  docs/SECURITY_MODEL.md
  docs/RELEASE_NOTES_1.0.0.md
]

missing_files = required_files.reject do |path|
  file = root / path
  file.file? && !file.zero?
end
abort "缺少文档：#{missing_files.join('、')}" unless missing_files.empty?

api = JSON.parse(api_path.read)
abort "API 清单格式必须是 1" unless api.fetch("format_version") == 1
abort "API 清单语言必须是 yanxu" unless api.fetch("language") == "yanxu"
abort "API 清单模块必须是言序HTML" unless api.fetch("module") == "言序HTML"

declarations = api.fetch("declarations")
class_declarations = declarations.select { |declaration| declaration["kind"] == "class" }
class_members = class_declarations.flat_map do |declaration|
  declaration.fetch("fields", []) + declaration.fetch("methods", [])
end

abort "顶层公开声明应为 30，实际为 #{declarations.length}" unless declarations.length == 30
abort "公开类成员应为 32，实际为 #{class_members.length}" unless class_members.length == 32

invalid_names = (declarations + class_members).reject do |item|
  item["name"].is_a?(String) && !item["name"].empty?
end
abort "API 清单含无效公开名称" unless invalid_names.empty?

api_document = (root / "docs/API.md").read
public_names = (declarations + class_members).map { |item| item.fetch("name") }.uniq
missing_names = public_names.reject { |name| api_document.include?("`#{name}") }
abort "API 文档缺少：#{missing_names.join('、')}" unless missing_names.empty?

markdown_files = root.glob("**/*.md")
unbalanced_fences = markdown_files.reject { |file| file.read.lines.count { |line| line.start_with?("```") }.even? }
unless unbalanced_fences.empty?
  abort "代码围栏不成对：#{unbalanced_fences.map { |file| file.relative_path_from(root) }.join('、')}"
end

broken_links = []
markdown_files.each do |file|
  file.read.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |link|
    next if link.match?(/\A(?:https?:|mailto:|#)/)

    relative = link.split("#", 2).first
    next if relative.empty?

    target = file.dirname / relative
    broken_links << "#{file.relative_path_from(root)}: #{link}" unless target.exist?
  end
end
abort "失效链接：\n#{broken_links.join("\n")}" unless broken_links.empty?

forbidden_placeholders = ["TODO", "FIXME", "计划完成", "理论支持", "预计成功"]
placeholder_hits = markdown_files.map do |file|
  content = file.read
  hit = forbidden_placeholders.find { |placeholder| content.include?(placeholder) }
  "#{file.relative_path_from(root)}: #{hit}" if hit
end.compact
abort "文档含占位陈述：\n#{placeholder_hits.join("\n")}" unless placeholder_hits.empty?

puts "文档通过：#{markdown_files.length} 个文件，#{declarations.length} 个顶层声明，#{class_members.length} 个类成员，#{public_names.length} 个去重名称"
