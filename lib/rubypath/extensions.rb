# frozen_string_literal: true

class Path
  # @!group File Extensions

  # Return list of all file extensions.
  #
  # @example
  #   Path.new('/path/to/template.de.html.erb').extensions
  #   #=> ['de', 'html', 'erb']
  #
  # @return [Array<String>] List of file extensions.
  #
  def extensions
    if dotfile?
      name.split('.')[2..-1]
    else
      name.split('.')[1..-1]
    end
  end
  alias exts extensions

  # Return last file extension.
  #
  # @example
  #   Path.new('/path/to/template.de.html.erb').extension
  #   #=> 'erb'
  #
  # @return [String] Last file extensions.
  #
  def extension
    extensions.last
  end
  alias ext extension

  # Return last file extension include dot character.
  #
  # @return [String] Ext name.
  # @see ::File.extname
  #
  def extname
    ::File.extname name
  end

  # Return the file name without any extensions.
  #
  # @example
  #   Path("template.de.html.slim").pure_name
  #   #=> "template"
  #
  # @example
  #   Path("~/.gitconfig").pure_name
  #   #=> ".gitconfig"
  #
  # @return [String] File name without extensions.
  #
  def pure_name
    if dotfile?
      name.split('.', 3)[0..1].join('.')
    else
      name.split('.', 2)[0]
    end
  end

  # Replace file extensions with given new ones or by a given
  # translation map.
  #
  # @overload replace_extensions(exts)
  #   Replace all extensions with given new ones. Number of given extensions
  #   does not need to match number of existing extensions.
  #
  #   @example
  #     Path('file.de.txt').replace_extensions(%w(en html))
  #     #=> <Path "file.en.html">
  #
  #   @example
  #     Path('file.de.mobile.html.haml').replace_extensions(%w(int txt))
  #     #=> <Path "file.int.txt">
  #
  #   @param exts [Array<String>] New extensions.
  #
  # @overload replace_extensions(ext, [ext, [..]])
  #   Replace all extensions with given new ones. Number of given extensions
  #   does not need to match number of existing extensions.
  #
  #   @example
  #     Path('file.de.txt').replace_extensions('en', 'html')
  #     #=> <Path "file.en.html">
  #
  #   @example
  #     Path('file.de.mobile.html.haml').replace_extensions('en', 'html')
  #     #=> <Path "file.en.html">
  #
  #   @example
  #     Path('file.de.txt').replace_extensions('html')
  #     #=> <Path "file.html">
  #
  #   @param ext [String] New extensions.
  #
  # @overload replace_extensions(map)
  #   Replace all matching extensions.
  #
  #   @example
  #     Path('file.de.html.haml').replace_extensions('de'=>'en', 'haml'=>'slim')
  #     #=> <Path "file.en.html.slim">
  #
  #   @param map [Hash<String, String>] Translation map as hash.
  #
  # @return [Path] Path to new filename.
  #
  # rubocop:disable AbcSize
  # rubocop:disable CyclomaticComplexity
  # rubocop:disable MethodLength
  # rubocop:disable PerceivedComplexity
  #
  def replace_extensions(*args)
    args.flatten!
    extensions = self.extensions

    if (replace = (args.last.is_a?(Hash) ? args.pop : nil))
      if args.empty?
        extensions.map! do |ext|
          replace[ext] ? replace[ext].to_s : ext
        end
      else
        raise ArgumentError.new 'Cannot replace extensions with array ' \
                                'and hash at the same time.'
      end
    else
      extensions = args.map(&:to_s)
    end

    if extensions == self.extensions
      self
    elsif only_filename?
      Path "#{pure_name}.#{extensions.join('.')}"
    else
      dirname.join "#{pure_name}.#{extensions.join('.')}"
    end
  end
  # rubocop:enable all

  # Replace last extension with one or multiple new extensions.
  #
  # @example
  #   Path('file.de.txt').replace_extension('html')
  #   #=> <Path "file.de.html">
  #
  # @example
  #   Path('file.de.txt').replace_extension('html', 'erb')
  #   #=> <Path "file.de.html.erb">
  #
  # @return [Path] Path to new filename.
  #
  def replace_extension(*args)
    extensions = self.extensions
    extensions.pop
    extensions += args.flatten

    replace_extensions extensions
  end
end
