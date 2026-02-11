// ========================================
// ABYSS VM - COMANDOS DEL BOT
// ========================================
// Separados para mantener orden.
// ========================================

const { AttachmentBuilder, EmbedBuilder } = require('discord.js');
const { exec, spawn } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

class AbyssCommands {
    constructor(config) {
        this.config = config;
        this.stats = {
            totalExecutions: 0,
            totalObfuscations: 0,
            uptime: Date.now()
        };
    }

    // Comando: !vm
    async handleVM(message, args) {
        if (!args.length) {
            return message.reply('❌ Tenés que poner código Luau, hermano.');
        }

        const code = args.join(' ');
        const status = await message.reply('⚡ Inicializando Abyss VM...');

        try {
            const jobId = crypto.randomBytes(4).toString('hex');
            const tempFile = path.join('/tmp', `abyss_${jobId}.lua`);
            
            await fs.writeFile(tempFile, code);
            
            const vmProcess = spawn('lua', [path.join(__dirname, '../vm/core.lua'), tempFile], {
                timeout: 30000,
                killSignal: 'SIGTERM'
            });

            let output = '';
            let error = '';

            vmProcess.stdout.on('data', (data) => output += data.toString());
            vmProcess.stderr.on('data', (data) => error += data.toString());

            vmProcess.on('close', async (code) => {
                await fs.unlink(tempFile).catch(() => {});
                
                if (code !== 0) {
                    return await status.edit(`❌ Error VM: ${error || 'Error desconocido'}`);
                }

                const embed = new EmbedBuilder()
                    .setColor(0x00FF00)
                    .setTitle('✅ ABYSS VM - EJECUCIÓN COMPLETADA')
                    .addFields(
                        { name: 'Job ID', value: jobId, inline: true },
                        { name: 'Output', value: output.substring(0, 100) + (output.length > 100 ? '...' : ''), inline: false }
                    )
                    .setTimestamp();

                await status.edit({ embeds: [embed] });
                this.stats.totalExecutions++;
            });

        } catch (e) {
            await status.edit(`❌ Error: ${e.message}`);
        }
    }

    // Comando: !vm-protect
    async handleProtect(message, args) {
        if (!args.length) {
            return message.reply('❌ Tenés que poner código para ofuscar.');
        }

        const code = args.join(' ');
        const status = await message.reply('🔒 Ofuscando con Abyss VM...');

        try {
            const jobId = crypto.randomBytes(4).toString('hex');
            const tempFile = path.join('/tmp', `abyss_${jobId}.lua`);
            const outputFile = path.join('/tmp', `abyss_${jobId}_obf.lua`);
            
            await fs.writeFile(tempFile, code);
            
            const obfProcess = spawn('lua', [
                path.join(__dirname, '../obfuscator/engine.lua'),
                tempFile,
                outputFile
            ], { timeout: 10000 });

            let obfuscated = '';
            let obfError = '';

            obfProcess.stdout.on('data', (data) => obfuscated += data.toString());
            obfProcess.stderr.on('data', (data) => obfError += data.toString());

            obfProcess.on('close', async (code) => {
                await fs.unlink(tempFile).catch(() => {});
                
                if (code !== 0 || !obfuscated) {
                    return await status.edit(`❌ Error ofuscador: ${obfError || 'Error desconocido'}`);
                }

                const buffer = Buffer.from(obfuscated);
                const attachment = new AttachmentBuilder(buffer, {
                    name: `abyss_${jobId}.lua`
                });

                const embed = new EmbedBuilder()
                    .setColor(0x9B59B6)
                    .setTitle('🔒 ABYSS VM - OFUSCACIÓN COMPLETADA')
                    .addFields(
                        { name: 'Job ID', value: jobId, inline: true },
                        { name: 'Tamaño', value: `${buffer.length} bytes`, inline: true },
                        { name: 'Anti-tamper', value: this.config.antitamper ? '✅ ACTIVADO' : '❌ DESACTIVADO', inline: true }
                    )
                    .setTimestamp();

                await status.edit({ embeds: [embed], files: [attachment] });
                this.stats.totalObfuscations++;
            });

        } catch (e) {
            await status.edit(`❌ Error: ${e.message}`);
        }
    }

    // Comando: !vm-bytecode
    async handleBytecode(message, args) {
        if (!args.length) {
            return message.reply('❌ Tenés que poner código para ver el bytecode.');
        }

        const code = args.join(' ');
        const status = await message.reply('🔍 Generando bytecode...');

        try {
            const jobId = crypto.randomBytes(4).toString('hex');
            const tempFile = path.join('/tmp', `abyss_${jobId}.lua`);
            
            await fs.writeFile(tempFile, code);
            
            const compileProcess = spawn('lua', [
                path.join(__dirname, '../vm/compiler.lua'),
                tempFile
            ], { timeout: 5000 });

            let bytecode = '';
            let compileError = '';

            compileProcess.stdout.on('data', (data) => bytecode += data.toString());
            compileProcess.stderr.on('data', (data) => compileError += data.toString());

            compileProcess.on('close', async (code) => {
                await fs.unlink(tempFile).catch(() => {});
                
                if (code !== 0 || !bytecode) {
                    return await status.edit(`❌ Error compilador: ${compileError || 'Error desconocido'}`);
                }

                const buffer = Buffer.from(bytecode);
                const attachment = new AttachmentBuilder(buffer, {
                    name: `bytecode_${jobId}.txt`
                });

                await status.edit({
                    content: '✅ Bytecode generado. **Solo nosotros entendemos esto.**',
                    files: [attachment]
                });
            });

        } catch (e) {
            await status.edit(`❌ Error: ${e.message}`);
        }
    }

    // Comando: !vm-stats
    async showStats(message) {
        const uptime = Math.floor((Date.now() - this.stats.uptime) / 1000);
        const hours = Math.floor(uptime / 3600);
        const minutes = Math.floor((uptime % 3600) / 60);

        const embed = new EmbedBuilder()
            .setColor(0x3498DB)
            .setTitle('📊 ABYSS VM - ESTADÍSTICAS')
            .addFields(
                { name: '⏱️ Uptime', value: `${hours}h ${minutes}m`, inline: true },
                { name: '📁 Ejecuciones', value: `${this.stats.totalExecutions}`, inline: true },
                { name: '🔐 Ofuscaciones', value: `${this.stats.totalObfuscations}`, inline: true }
            )
            .setTimestamp();

        await message.reply({ embeds: [embed] });
    }

    // Comando: !vm-help
    async showHelp(message) {
        const embed = new EmbedBuilder()
            .setColor(0x9B59B6)
            .setTitle('🔥 ABYSS VM - MANUAL OFICIAL')
            .setDescription('**La máquina virtual que rompe decompiladores**')
            .addFields(
                { name: '📌 COMANDOS', value: `
\`!vm <código>\` - Ejecutar código en Abyss VM
\`!vm-protect <código>\` - Ofuscar código con Abyss
\`!vm-bytecode <código>\` - Ver bytecode generado
\`!vm-stats\` - Estadísticas del bot
\`!vm-help\` - Esta ayuda
                ` },
                { name: '🛡️ PROTECCIONES', value: `
✅ VM propia (bytecode personalizado)
✅ Anti-tamper (7 capas)
✅ Control Flow Flattening
✅ Polimorfismo dinámico
✅ 100% local, 0 dependencias
                ` }
            )
            .setFooter({ text: 'Abyss VM - Solo para los que entienden' })
            .setTimestamp();

        await message.reply({ embeds: [embed] });
    }
}

module.exports = AbyssCommands;
