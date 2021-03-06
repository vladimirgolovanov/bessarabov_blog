use Test::More;

# https://tech.yandex.ru/speller/

use strict;
use warnings FATAL => 'all';
use utf8;
use open qw(:std :utf8);

use File::Slurp;
use HTTP::Tiny;
use JSON::PP;
use Text::Markdown qw(markdown);

my @IGNORE = qw(
    3rd
    AngularJS
    Ansible
    Appleton
    Beatty
    Berczuk
    Bezos
    Brin
    CHANGEME
    CPAN
    CSRF
    Cem
    Construx
    Cumberbatch
    Downey
    EOM
    Elon
    Esc
    Falk
    FileBase
    GitHub
    Goddard
    Hemsworth
    Kaner
    Karl
    Larman
    McConnell
    Monit
    Munin
    Nadella
    Nagios
    Nguyen
    PSGI
    Playbook
    Pratt
    Satya
    SemVer
    TODO
    UML
    Wiegers
    YAPC
    YNAB
    Zabbix
    ansible
    bessarabov
    boot2docker
    cal
    com
    github
    jenkins
    letsencrypt
    linux
    nginx
    playbook
    printf
    projecta
    projectb
    readthedocs
    reddit
    ru
    screencast
    sprintf
    ssl
    ssls
    subj
    tmp
    Макконнелла
    Масяня
    Мда
    ПДД
    баг
    бекап
    бекапить
    гитхаб
    докерный
    докерных
    нажимабельна
    наэксперементировали
    однострочник
    сгенерит
    суперское
    файлик
);

my %IGNORE_HASH = map { $_ => 1 } @IGNORE;

sub get_content {
    my ($file_name) = @_;

    my $content = read_file(
        $file_name,
        {
            binmode => ':utf8',
        },
    );

    return $content;
}

sub remove_meta_information {

    $_[0] =~ s/date_time: .*//;

    return 1;
}

sub remove_code {

    $_[0] =~ s/^\s{4}.*//mg;

    return 1;
}

sub remove_links {

    $_[0] =~ s{https?://[^\s\[\]\(\)]+}{Link}g;

    return 1;
}

sub remove_ignore_words {

    $_[0] = [
        grep {
            not $IGNORE_HASH{$_->{word}}
        } @{$_[0]}
    ];

    return 1;
}

sub get_check_result_from_yandex_speller {
    my ($html) = @_;

    my $response = HTTP::Tiny->new()->post_form(
        'https://speller.yandex.net/services/spellservice.json/checkText',
        {
            text => $html,
            ie => 'utf-8',
            format => 'html',
        }
    );

    is($response->{status}, 200, 'Got 200 status code from speller.yandex.net');

    my $check_result = decode_json $response->{content};

    return $check_result;
}

sub check_file {
    my ($file_name) = @_;

    my $content = get_content($file_name);

    remove_meta_information($content);
    remove_code($content);
    remove_links($content);

    my $html = markdown($content);

    my $check_result = get_check_result_from_yandex_speller($html);

    remove_ignore_words($check_result);

    if (scalar @{$check_result} == 0) {
        pass('Speller found no errors in file "' . $file_name . '"');
    } else {
        fail('Speller found errors in file "' . $file_name . '"');
        foreach my $element (@{$check_result}) {
            note(
                get_text( $element->{word}, $element->{s} )
            );
        }
    }

    return 1;
}

sub get_text {
    my ($word, $suggestions) = @_;

    my $text = sprintf 'Unknown word: "%s"', $word;

    if (@{$suggestions}) {
        $text .= sprintf ' (Suggestions: "%s")', join('", "', @{$suggestions});
    }

    return $text;
}

sub main_in_test {

    binmode Test::More->builder->output, ":utf8";
    binmode Test::More->builder->failure_output, ":utf8";

    pass('Loaded ok');

    my $file_name_from_agrv = $ARGV[0];

    if ($file_name_from_agrv) {
        check_file($file_name_from_agrv);
    } else {
        my @files = <*_ru.md>;

        # TODO - поправить все файлы из этого списка
        my @files_to_ignore = (
            'als_ce_bucket_challenge_ru.md',
            'angularjs_vs_template_toolkit_ru.md',
            'bret_victor_ru.md',
            'cpan_ru.md',
            'css_selectors_order_ru.md',
            'curry_monitoring_ru.md',
            'dailyprogrammer_111_ru.md',
            'docker_commands_ru.md',
            'docker_compose_guideline_ru.md',
            'docker_volumes_experiments_ru.md',
            'drivers_license_test_blank_ru.md',
            'external_links_ru.md',
            'git_low_level_assemblage_ru.md',
            'git_svn_ru.md',
            'hill_ru.md',
            'how_i_pay_for_internet_in_time_ru.md',
            'how_to_run_swift_playground_ru.md',
            'hpmor_text_statistics_ru.md',
            'mac_os_internet_switch_on_off_ru.md',
            'mac_os_perl_versions_ru.md',
            'macbook_keyboard_ru.md',
            'metacpan_likes_ru.md',
            'moscow_drivers_license_exam_map_ru.md',
            'moscow_pm_meetings_ru.md',
            'ok_fail_terminology_ru.md',
            'perl_boolean_barewords_ru.md',
            'perl_data_printer_ru.md',
            'perl_library_moment_get_weekday_number_ru.md',
            'perl_oneliners_ru.md',
            'perl_pretty_print_json_ru.md',
            'perl_printf_sprintf_ru.md',
            'perl_retry_module_ru.md',
            'perl_style_guide_ru.md',
            'perl_unicode_ru.md',
            'permitted_speed_ru.md',
            'php_was_not_written_in_perl_ru.md',
            'python_oneliner_to_start_webserver_ru.md',
            'temporary_work_directory_ru.md',
            'the_magellanic_cloud_quotation_ru.md',
            'view_data_structure_diff_ru.md',
            'why_every_site_should_use_https_ru.md',
            'why_google_dont_promote_driverless_car_in_car_racing_ru.md',
            'wireless_headset_for_iphone_ru.md',
        );

        foreach my $file_name (@files) {
            next if grep { $_ eq $file_name } @files_to_ignore;
            check_file($file_name);
        }

    }

    done_testing();
}
main_in_test();
