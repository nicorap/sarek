include { initOptions; saveFiles; getSoftwareName } from './../functions'

process GATK_HAPLOTYPECALLER {
    label 'MEMORY_SINGLECPU_TASK_SQ'
    label 'CPUS_2'

    tag "${meta.id}-${interval.baseName}"

    container "quay.io/biocontainers/gatk4-spark:4.1.8.1--0"

    conda (params.conda ? "bioconda::gatk4-spark=4.1.8.1" : null)

    input:
        tuple val(meta), path(bam), path(bai), file(interval)
        path dbsnp
        path dbsnpIndex
        path dict
        path fasta
        path fai

    output:
        tuple val(meta), path("${interval.baseName}_${meta.id}.g.vcf"),                 emit: gvcf
        tuple val(meta), path(interval), path("${interval.baseName}_${meta.id}.g.vcf"), emit: interval_gvcf


    script:
    intervalsOptions = params.no_intervals ? "" : "-L ${interval}"
    dbsnpOptions = params.dbsnp ? "--D ${dbsnp}" : ""
    """
    gatk --java-options "-Xmx${task.memory.toGiga()}g -Xms6000m -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10" \
        HaplotypeCaller \
        -R ${fasta} \
        -I ${bam} \
        ${intervalsOptions} \
        ${dbsnpOptions} \
        -O ${interval.baseName}_${meta.id}.g.vcf \
        -ERC GVCF
    """
}
